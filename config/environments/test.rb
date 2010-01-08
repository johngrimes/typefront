# Settings specified here will take precedence over those in config/environment.rb

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :test
  ::GATEWAY = ActiveMerchant::Billing::Base.gateway(:eway).new(
    :login => '87654321', 
    :username => 'test@eway.com.au', 
    :password => 'test123', 
    :engine => :managed
  )
end

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

$DOMAIN = 'staging.typefront.com'
$HOST = "http://#{$DOMAIN}"
$HOST_SSL = "http://#{$DOMAIN}"

config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_url_options = { :host => $DOMAIN }
ActionMailer::Base.delivery_method = :test
config.action_mailer.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => $DOMAIN,
  :authentication => :plain,
  :user_name => 'noreply@typefront.com',
  :password => '2001gattaca'
}
