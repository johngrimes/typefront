require 'rubygems'

RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'mysql',
    :version => '2.8.1'
  config.gem 'sqlite3-ruby',
    :lib => 'sqlite3',
    :version => '1.3.0'

  config.gem 'haml',
    :version => '2.2.13'
  config.gem 'chriseppstein-compass',
    :lib => 'compass',
    :version => '0.8.17'
  config.gem 'chriseppstein-compass-960-plugin',
    :lib => 'ninesixty',
    :version => '0.9.7'

  config.gem 'authlogic',
    :version => '2.1.5'
  config.gem 'paperclip',
    :version => '2.3.3'
  config.gem 'delayed_job',
    :version => '2.0.3'
  config.gem 'will_paginate',
    :version => '2.3.14'
  config.gem 'smurf',
    :version => '1.0.4'

  # ActiveMerchant dependencies
  config.gem 'soap4r',
    :lib => false,
    :version => '1.5.8'
  config.gem 'money',
    :version => '3.0.2'

  # Rake task dependencies
  config.gem 'fastercsv',
    :lib => false,
    :version => '1.5.3'

  # Test dependencies
  config.gem 'rspec', 
    :lib => false,
    :version => '1.2.9'
  config.gem 'rspec-rails', 
    :lib => false,
    :version => '1.2.9'
  config.gem 'mocha',
    :lib => false,
    :version => '0.9.8'
  config.gem 'factory_girl',
    :lib => false,
    :version => '1.3.0'

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
