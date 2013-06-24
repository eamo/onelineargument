class PagesController < ApplicationController
  
  
  def home
    if user_signed_in?
      tweet_client = Twitter::Client.new(
        :oauth_token => current_user.token,
        :oauth_token_secret => current_user.secret
      )
      @tweets = tweet_client.search("if then")
      @theseTweets = []
      @tweets.statuses.each do |tweet|
        #check if tweet exists
        if defined?(LogicTweet.find_by_id_str(tweet.attrs[:id_str]))
          then
            puts "sup"
          else
            lt = LogicTweet.find_or_initialize_by_id_str(tweet.attrs[:id_str])
            lt.tweet_created_at =tweet[:created_at]
            lt.id_str = tweet.attrs[:id_str]
            lt.text = tweet[:text]
            lt.user_id_str = tweet.attrs[:user][:id_str]
            lt.profile_image_url = tweet[:user][:profile_image_url]
            lt.favorited = tweet[:retweet_count]
            lt.retweeted = tweet[:favorite_count]
            lt.screen_name = tweet[:user][:screen_name]
            lt.followers_count = tweet[:user][:followers_count]
            lt.friends_count = tweet[:user][:friends_count]
            lt.save!
            if (tweet.attrs[:retweeted_status] != nil)
              rt = tweet.attrs[:retweeted_status]
              #puts rt[:created_at]
              lt = LogicTweet.find_or_initialize_by_id_str(rt[:id_str])
              lt.tweet_created_at = rt[:created_at]
              lt.id_str = rt[:id_str]
              lt.text = rt[:text]
              lt.user_id_str = rt[:user][:id_str]
              lt.profile_image_url = rt[:user][:profile_image_url]
              lt.favorited = rt[:retweet_count]
              lt.retweeted = rt[:favorite_count]
              lt.screen_name = rt[:user][:screen_name]
              lt.followers_count = rt[:user][:followers_count]
              lt.friends_count = rt[:user][:friends_count]
              lt.save!
            end
            
            @theseTweets.push(lt)
            if params[:type] != 'new'
              @theseTweets = LogicTweet.all.limit(20).order('retweeted desc')
            end
          end
      end
      
#      File.open("eamo", "w") do |f|
#        f.write(@tweets.to_yaml)
#        puts f
#      end
    end
  end
end
