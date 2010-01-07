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

ActiveRecord::Schema.define(:version => 20100107105825) do

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
    t.string   "original_file_name"
    t.string   "original_content_type"
    t.integer  "original_file_size"
    t.datetime "original_updated_at"
    t.string   "original_format"
  end

  create_table "formats", :force => true do |t|
    t.string   "file_extension"
    t.string   "description"
    t.string   "distribution_file_name"
    t.string   "distribution_content_type"
    t.integer  "distribution_file_size"
    t.datetime "distribution_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "font_id"
  end

  add_index "formats", ["font_id", "file_extension"], :name => "index_formats_on_font_id_and_file_extension", :unique => true

  create_table "invoices", :force => true do |t|
    t.integer  "amount",         :limit => 10, :precision => 10, :scale => 0
    t.string   "description"
    t.datetime "paid_at"
    t.string   "auth_code"
    t.string   "gateway_txn_id"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logged_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "font_id"
    t.string   "action"
    t.string   "remote_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "referer"
    t.string   "origin"
    t.string   "user_agent"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.integer  "user_id"
    t.string   "status"
    t.integer  "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_type"
    t.integer  "subscription_level"
    t.boolean  "delete_account"
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
    t.string   "subscription_name"
    t.integer  "requests_allowed"
    t.datetime "subscription_renewal"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.integer  "subscription_amount"
    t.integer  "fonts_allowed"
    t.integer  "subscription_level"
    t.string   "perishable_token"
    t.boolean  "active",               :default => false, :null => false
    t.string   "card_name"
    t.string   "card_type"
    t.date     "card_expiry"
    t.string   "gateway_customer_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
