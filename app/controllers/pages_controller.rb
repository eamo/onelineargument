class PagesController < ApplicationController
  
  
  def home
    if user_signed_in?
      tweet_client = Twitter::Client.new(
        :oauth_token => current_user.token,
        :oauth_token_secret => current_user.secret
      )
      if params[:type] == 'me'
        @tweets = tweet_client.user_timeline(:uid => current_user.uid)
        @theseTweets = []
        @tweets.each do |tweet|
          if tweet.text.downcase.include?("if") && tweet.text.downcase.include?("then")
            lt = LogicTweet.find_or_initialize_by_id_str(tweet.attrs[:id_str])
            lt.tweet_created_at =tweet[:created_at]
            lt.id_str = tweet.attrs[:id_str]
            lt.text = tweet[:text]
            lt.user_id_str = tweet.attrs[:user][:id_str]
            lt.profile_image_url = tweet[:user][:profile_image_url]
            lt.favorited = tweet[:favorite_count]
            lt.retweeted = tweet[:retweet_count]
            lt.screen_name = tweet[:user][:screen_name]
            lt.followers_count = tweet[:user][:followers_count]
            lt.friends_count = tweet[:user][:friends_count]
            lt.save!
            @theseTweets.push(lt)
          end
        end
      else  
        @tweets = tweet_client.search("if then", :count => 100, :lang => 'en', :result_type => "recent")
        @theseTweets = []
        @tweets.statuses.each do |tweet|
          #check if tweet exists
          lt = LogicTweet.find_or_initialize_by_id_str(tweet.attrs[:id_str])
          lt.tweet_created_at =tweet[:created_at]
          lt.id_str = tweet.attrs[:id_str]
          lt.text = tweet[:text]
          lt.user_id_str = tweet.attrs[:user][:id_str]
          lt.profile_image_url = tweet[:user][:profile_image_url]
          lt.favorited = tweet[:favorite_count]
          lt.retweeted = tweet[:retweet_count]
          lt.screen_name = tweet[:user][:screen_name]
          lt.followers_count = tweet[:user][:followers_count]
          lt.friends_count = tweet[:user][:friends_count]
          lt.save!
          if (tweet.attrs[:retweeted_status] != nil)
            rt = tweet.attrs[:retweeted_status]
            lt = LogicTweet.find_or_initialize_by_id_str(rt[:id_str])
            lt.tweet_created_at = rt[:created_at]
            lt.id_str = rt[:id_str]
            lt.text = rt[:text]
            lt.user_id_str = rt[:user][:id_str]
            lt.profile_image_url = rt[:user][:profile_image_url]
            lt.favorited = rt[:favorite_count]
            lt.retweeted = rt[:retweet_count]
            lt.screen_name = rt[:user][:screen_name]
            lt.followers_count = rt[:user][:followers_count]
            lt.friends_count = rt[:user][:friends_count]
            lt.save!
          end
          @theseTweets.push(lt)
          if params[:type] != 'new'
            @theseTweets = LogicTweet.all.limit(10).order('retweeted desc')
          end
          @theseTweets = @theseTweets[0..9]
        end
      end
    elsif params[:type] == nil && params[:other] == nil
      @candidateTweets = LogicTweet.all.order('retweeted desc')
      @theseTweets = []
      @candidateTweets.each do |tweet|
        if tweet.text[0,2] != "RT"
          @theseTweets.push(tweet)
        end
      end
      @theseTweets = @theseTweets[0..9]
      @theseTweets.each do |tweet|   
      end
    end
  end
  
   def other
     if user_signed_in?
       tweet_client = Twitter::Client.new(
         :oauth_token => current_user.token,
         :oauth_token_secret => current_user.secret
       )
       @tweets = tweet_client.user_timeline(params[:other], :count => 200)
       @theseTweets = []
       puts @tweets
       @tweets.each do |tweet|
         if tweet.text.include?("if") && tweet.text.include?("then")
           puts tweet.text
           lt = LogicTweet.find_or_initialize_by_id_str(tweet.attrs[:id_str])
           lt.tweet_created_at =tweet[:created_at]
           lt.id_str = tweet.attrs[:id_str]
           lt.text = tweet[:text]
           lt.user_id_str = tweet.attrs[:user][:id_str]
           lt.profile_image_url = tweet[:user][:profile_image_url]
           lt.favorited = tweet[:favorite_count]
           lt.retweeted = tweet[:retweet_count]
           lt.screen_name = tweet[:user][:screen_name]
           lt.followers_count = tweet[:user][:followers_count]
           lt.friends_count = tweet[:user][:friends_count]
           lt.save!
           @theseTweets.push(lt)
         end
        end
       end
     render :home
   end
end
