require 'rubygems'
gem 'soap4r'

RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'mysql'
  config.gem 'sqlite3-ruby',
    :lib => 'sqlite3'

  config.gem 'haml',
    :version => '2.2.13'
  config.gem 'chriseppstein-compass',
    :lib => 'compass',
    :version => '0.8.17'
  config.gem 'chriseppstein-compass-960-plugin',
    :lib => 'ninesixty',
    :version => '0.9.7'

  config.gem 'authlogic' # Ruled out
  config.gem 'paperclip' # Ruled out
  config.gem 'delayed_job' # Ruled out
#   config.gem 'will_paginate' # Ruled out
#   config.gem 'smurf' # Ruled out

  # ActiveMerchant dependencies
#   config.gem 'soap4r' # Ruled out
  config.gem 'money'

  # Rake task dependencies
  config.gem 'fastercsv'

  # Test dependencies
  config.gem 'rspec', 
    :lib => false
  config.gem 'rspec-rails', 
    :lib => false
  config.gem 'mocha'
  config.gem 'factory_girl'

  config.action_controller.session_store = :active_record_store

  config.time_zone = 'UTC'

  config.action_mailer.smtp_settings = {
    :tls => true,
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'typefront.com',
    :authentication => :plain,
    :user_name => 'noreply@typefront.com',
    :password => '2001gattaca'
  }
end

ExceptionNotifier.exception_recipients = %w(contact@smallspark.com.au)
ExceptionNotifier.sender_address = %("TypeFront" <noreply@typefront.com>)

COUNTRIES_JSON = "#{RAILS_ROOT}/config/reference_data/countries.json"

ENV['TEST_XHTML'] = 'false'
