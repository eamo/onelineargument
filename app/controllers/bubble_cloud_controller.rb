class BubbleCloudController < ApplicationController
  def view1
    if user_signed_in?
      tweet_client = Twitter::Client.new(
        :oauth_token => current_user.token,
        :oauth_token_secret => current_user.secret
      )
        @tweets = tweet_client.search("'TDF100' Froome OR Valverde OR Mollema OR Dam OR Kreuziger OR Contador OR Rojas OR Martin OR Oliver OR Costa", :count => 200, :lang => 'en')
        @tweets.statuses.each do |tweet|
          lt = LogicTweet.find_or_initialize_by(text: tweet.attrs[:text])
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
          lt.tweet_scrape_category = "leTour"
          lt.save!(:validate => false)
          @theseTweets = LogicTweet.where(tweet_scrape_category: 'leTour').limit(200)
        end
      end
      respond_to do |format|
        format.html {}
        format.csv { send_data @theseTweets.to_csv }
      end
    end

  def view2
  end

  def view3
  end

  def view4
  end
  
  
end
