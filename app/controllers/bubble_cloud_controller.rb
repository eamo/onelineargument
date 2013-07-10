class BubbleCloudController < ApplicationController
  def view1

      respond_to do |format|
        format.html {}
        format.csv {
          if user_signed_in?
            tweet_client = Twitter::Client.new(
              :oauth_token => current_user.token,
              :oauth_token_secret => current_user.secret
            )
            saveTweets(tweet_client.search("'TDF' Froome", :count => 200))
            saveTweets(tweet_client.search("'TDF' Valverde ", :count => 200))
            saveTweets(tweet_client.search("'TDF' Mollema", :count => 200))
            saveTweets(tweet_client.search("'TDF' Dam", :count => 200))
            saveTweets(tweet_client.search("'TDF' Kreuziger", :count => 200))
            saveTweets(tweet_client.search("'TDF' Contador", :count => 200))
            saveTweets(tweet_client.search("'TDF' Rojas", :count => 200))
            saveTweets(tweet_client.search("'TDF' Martin", :count => 200))
            saveTweets(tweet_client.search("'TDF' Rodriguez", :count => 200))
            saveTweets(tweet_client.search("'TDF' Costa", :count => 200))
          end
            @theseTweets = LogicTweet.where(tweet_scrape_category: "leTour")
            send_data @theseTweets.to_csv

        }
    end
  end
  def view2
  end

  def view3
  end

  def view4
  end
  
  private
  def saveTweets(tweets)
    tweets.statuses.each do |tweet|
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
    end
  end
  
end
