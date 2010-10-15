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

ActiveRecord::Schema.define(:version => 20101015003333) do

  create_table "dates", :primary_key => "date_id", :force => true do |t|
    t.date    "date",                                                      :null => false
    t.integer "timestamp",            :limit => 8,                         :null => false
    t.string  "weekend",              :limit => 10, :default => "Weekday", :null => false
    t.string  "day_of_week",          :limit => 10,                        :null => false
    t.string  "month",                :limit => 10,                        :null => false
    t.integer "month_day",                                                 :null => false
    t.integer "year",                                                      :null => false
    t.string  "week_starting_monday", :limit => 2,                         :null => false
  end

  add_index "dates", ["date"], :name => "date", :unique => true
  add_index "dates", ["year", "week_starting_monday"], :name => "year_week"

  create_table "domains", :force => true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "font_id"
  end

  create_table "font_formats", :force => true do |t|
    t.string   "file_extension"
    t.string   "description"
    t.string   "distribution_file_name"
    t.string   "distribution_content_type"
    t.integer  "distribution_file_size"
    t.datetime "distribution_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "font_id"
    t.boolean  "active"
    t.text     "output"
    t.boolean  "failed",                    :default => false, :null => false
  end

  add_index "font_formats", ["font_id", "file_extension"], :name => "index_formats_on_font_id_and_file_extension", :unique => true

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
    t.text     "description"
    t.text     "vendor_url"
    t.text     "designer_url"
    t.text     "license"
    t.text     "license_url"
    t.string   "preferred_family"
    t.string   "preferred_subfamily"
    t.string   "compatible_full"
    t.text     "sample_text"
    t.integer  "user_id"
    t.string   "original_file_name"
    t.string   "original_content_type"
    t.integer  "original_file_size"
    t.datetime "original_updated_at"
    t.string   "original_format"
    t.integer  "generate_jobs_pending", :default => 0, :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "amount"
    t.text     "description"
    t.datetime "paid_at"
    t.string   "auth_code"
    t.string   "gateway_txn_id"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "logged_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "font_id"
    t.string   "action"
    t.string   "remote_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "referer"
    t.text     "origin"
    t.text     "user_agent"
    t.string   "format"
    t.decimal  "response_time", :precision => 10, :scale => 3
  end

  create_table "mv_stats_formats_breakdown", :id => false, :force => true do |t|
    t.integer "ttf",  :limit => 8
    t.integer "otf",  :limit => 8
    t.integer "eot",  :limit => 8
    t.integer "woff", :limit => 8
    t.integer "svg",  :limit => 8
  end

  create_table "mv_stats_plan_breakdown", :id => false, :force => true do |t|
    t.integer "free",  :limit => 8
    t.integer "plus",  :limit => 8
    t.integer "power", :limit => 8
  end

  create_table "mv_stats_requests", :id => false, :force => true do |t|
    t.date    "date"
    t.integer "requests",      :limit => 8
    t.decimal "response_time"
  end

  create_table "mv_stats_users_joined", :id => false, :force => true do |t|
    t.date    "date"
    t.integer "free",  :limit => 8
    t.integer "plus",  :limit => 8
    t.integer "power", :limit => 8
  end

  create_table "mv_stats_users_total", :id => false, :force => true do |t|
    t.date    "date"
    t.decimal "inactive"
    t.decimal "free"
    t.decimal "paying"
  end

  create_table "numbers", :id => false, :force => true do |t|
    t.integer "number", :limit => 8
  end

  create_table "numbers_small", :id => false, :force => true do |t|
    t.integer "number"
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
    t.string   "masked_card_number"
    t.integer  "login_count",          :default => 0,     :null => false
    t.integer  "failed_login_count",   :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  create_view "stats_formats_breakdown", "SELECT ttf.count AS ttf, otf.count AS otf, eot.count AS eot, woff.count AS woff, svg.count AS svg FROM (SELECT count(*) AS count FROM logged_requests WHERE ((((logged_requests.format)::text = 'ttf'::text) AND (date(logged_requests.created_at) >= (('now'::text)::date - '3 mons'::interval))) AND (date(logged_requests.created_at) <= ('now'::text)::date))) ttf, (SELECT count(*) AS count FROM logged_requests WHERE ((((logged_requests.format)::text = 'otf'::text) AND (date(logged_requests.created_at) >= (('now'::text)::date - '3 mons'::interval))) AND (date(logged_requests.created_at) <= ('now'::text)::date))) otf, (SELECT count(*) AS count FROM logged_requests WHERE ((((logged_requests.format)::text = 'eot'::text) AND (date(logged_requests.created_at) >= (('now'::text)::date - '3 mons'::interval))) AND (date(logged_requests.created_at) <= ('now'::text)::date))) eot, (SELECT count(*) AS count FROM logged_requests WHERE ((((logged_requests.format)::text = 'woff'::text) AND (date(logged_requests.created_at) >= (('now'::text)::date - '3 mons'::interval))) AND (date(logged_requests.created_at) <= ('now'::text)::date))) woff, (SELECT count(*) AS count FROM logged_requests WHERE ((((logged_requests.format)::text = 'svg'::text) AND (date(logged_requests.created_at) >= (('now'::text)::date - '3 mons'::interval))) AND (date(logged_requests.created_at) <= ('now'::text)::date))) svg;", :force => true do |v|
    v.column :ttf
    v.column :otf
    v.column :eot
    v.column :woff
    v.column :svg
  end

  create_view "stats_plan_breakdown", "SELECT f.count AS free, p.count AS plus, pp.count AS power FROM (SELECT count(*) AS count FROM users WHERE ((users.subscription_level = 0) AND (users.active = true))) f, (SELECT count(*) AS count FROM users WHERE ((users.subscription_level = 1) AND (users.active = true))) p, (SELECT count(*) AS count FROM users WHERE ((users.subscription_level = 2) AND (users.active = true))) pp;", :force => true do |v|
    v.column :free
    v.column :plus
    v.column :power
  end

  create_view "stats_requests", "SELECT requests.date, requests.requests, response.response_time FROM ((SELECT dates.date, count(r.id) AS requests FROM (dates LEFT JOIN logged_requests r ON ((dates.date = date(r.created_at)))) WHERE ((dates.date >= (('now'::text)::date - '3 mons'::interval)) AND (dates.date < ('now'::text)::date)) GROUP BY dates.date) requests JOIN (SELECT dates.date, round((avg(l.response_time) * (1000)::numeric)) AS response_time FROM (dates LEFT JOIN logged_requests l ON (((dates.date = date(l.created_at)) AND ((l.format)::text = ANY ((ARRAY['ttf'::character varying, 'otf'::character varying, 'woff'::character varying, 'eot'::character varying, 'svg'::character varying])::text[]))))) WHERE ((dates.date >= (('now'::text)::date - '3 mons'::interval)) AND (dates.date < ('now'::text)::date)) GROUP BY dates.date) response ON ((requests.date = response.date)));", :force => true do |v|
    v.column :date
    v.column :requests
    v.column :response_time
  end

  create_view "stats_users_joined", "SELECT free.date, free.users_joined AS free, plus.users_joined AS plus, power.users_joined AS power FROM (((SELECT dates.date, count(u.id) AS users_joined FROM (dates LEFT JOIN users u ON ((((dates.date = date(u.created_at)) AND (u.active = true)) AND (u.subscription_level = 0)))) WHERE ((dates.date >= (('now'::text)::date - '3 mons'::interval)) AND (dates.date < ('now'::text)::date)) GROUP BY dates.date) free JOIN (SELECT dates.date, count(u.id) AS users_joined FROM (dates LEFT JOIN users u ON ((((dates.date = date(u.created_at)) AND (u.active = true)) AND (u.subscription_level = 1)))) WHERE ((dates.date >= (('now'::text)::date - '3 mons'::interval)) AND (dates.date < ('now'::text)::date)) GROUP BY dates.date) plus ON ((free.date = plus.date))) JOIN (SELECT dates.date, count(u.id) AS users_joined FROM (dates LEFT JOIN users u ON ((((dates.date = date(u.created_at)) AND (u.active = true)) AND (u.subscription_level = 2)))) WHERE ((dates.date >= (('now'::text)::date - '3 mons'::interval)) AND (dates.date < ('now'::text)::date)) GROUP BY dates.date) power ON ((free.date = power.date)));", :force => true do |v|
    v.column :date
    v.column :free
    v.column :plus
    v.column :power
  end

  create_view "stats_users_total", "SELECT inactive.date, inactive.users AS inactive, free.users AS free, paying.users AS paying FROM (((SELECT d.date, sum(j.users_joined) AS users FROM (dates d LEFT JOIN (SELECT dates.date, count(u.id) AS users_joined FROM (dates LEFT JOIN users u ON (((dates.date = date(u.created_at)) AND (u.active = false)))) GROUP BY dates.date) j ON (((j.date <= d.date) AND (j.date >= '2010-02-05'::date)))) WHERE ((d.date >= (('now'::text)::date - '3 mons'::interval)) AND (d.date <= ('now'::text)::date)) GROUP BY d.date) inactive JOIN (SELECT d.date, sum(j.users_joined) AS users FROM (dates d LEFT JOIN (SELECT dates.date, count(u.id) AS users_joined FROM (dates LEFT JOIN users u ON ((((dates.date = date(u.created_at)) AND (u.active = true)) AND (u.subscription_level = 0)))) GROUP BY dates.date) j ON (((j.date <= d.date) AND (j.date >= '2010-02-05'::date)))) WHERE ((d.date >= (('now'::text)::date - '3 mons'::interval)) AND (d.date <= ('now'::text)::date)) GROUP BY d.date) free ON ((inactive.date = free.date))) JOIN (SELECT d.date, sum(j.users_joined) AS users FROM (dates d LEFT JOIN (SELECT dates.date, count(u.id) AS users_joined FROM (dates LEFT JOIN users u ON ((((dates.date = date(u.created_at)) AND (u.active = true)) AND (u.subscription_level <> 0)))) GROUP BY dates.date) j ON (((j.date <= d.date) AND (j.date >= '2010-02-05'::date)))) WHERE ((d.date >= (('now'::text)::date - '3 mons'::interval)) AND (d.date <= ('now'::text)::date)) GROUP BY d.date) paying ON ((inactive.date = paying.date)));", :force => true do |v|
    v.column :date
    v.column :inactive
    v.column :free
    v.column :paying
  end

end
