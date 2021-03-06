# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130624091406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "logic_tweets", force: true do |t|
    t.date     "tweet_created_at"
    t.string   "id_str"
    t.string   "text"
    t.string   "user_id_str"
    t.string   "profile_image_url"
    t.integer  "favorited"
    t.integer  "retweeted"
    t.string   "screen_name"
    t.integer  "followers_count"
    t.integer  "friends_count"
    t.string   "tweet_scrape_category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logic_tweets", ["id_str"], name: "index_logic_tweets_on_id_str", using: :btree
  add_index "logic_tweets", ["retweeted"], name: "index_logic_tweets_on_retweeted", using: :btree
  add_index "logic_tweets", ["tweet_scrape_category"], name: "index_logic_tweets_on_tweet_scrape_category", using: :btree
  add_index "logic_tweets", ["user_id_str"], name: "index_logic_tweets_on_user_id_str", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
  end

end
