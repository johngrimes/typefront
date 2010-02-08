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

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

$DOMAIN = 'typefront.local:3000'
$HOST = "http://#{$DOMAIN}"
$HOST_SSL = "http://#{$DOMAIN}"
$FAILED_FONT_DIR = "#{RAILS_ROOT}/public/system/failed_fonts"

config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_url_options = { :host => $DOMAIN }
ActionMailer::Base.delivery_method = :smtp
