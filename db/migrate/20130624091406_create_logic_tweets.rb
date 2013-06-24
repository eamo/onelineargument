class CreateLogicTweets < ActiveRecord::Migration
  def change
    create_table :logic_tweets do |t|
      t.date :tweet_created_at
      t.string :id_str
      t.string :text
      t.string :user_id_str
      t.string :profile_image_url
      t.integer :favorited
      t.integer :retweeted
      t.string :screen_name
      t.integer :followers_count
      t.integer :friends_count
    
      t.timestamps
    end
    
    add_index :logic_tweets, :retweeted
    add_index :logic_tweets, :user_id_str
    add_index :logic_tweets, :id_str, :unique => true
  end
end
