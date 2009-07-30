# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090729190628) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :force => true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "font_id"
  end

  create_table "fonts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "distribution_file_name"
    t.string   "distribution_content_type"
    t.integer  "distribution_file_size"
    t.datetime "distribution_updated_at"
    t.string   "copyright"
    t.string   "font_family"
    t.string   "font_subfamily"
    t.string   "font_name"
    t.string   "version"
    t.string   "trademark"
    t.string   "manufacturer"
    t.string   "designer"
    t.string   "description"
    t.string   "vendor_url"
    t.string   "designer_url"
    t.string   "license"
    t.string   "license_url"
    t.string   "preferred_family"
    t.string   "preferred_subfamily"
    t.string   "compatible_full"
    t.string   "sample_text"
    t.integer  "user_id"
  end

  create_table "logged_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "font_id"
    t.string   "action"
    t.string   "remote_ip"
    t.string   "request_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "subscription_level"
    t.integer  "request_credits"
    t.string   "subscription_expires_at"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
  end

end
