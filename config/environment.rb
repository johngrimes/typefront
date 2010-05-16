require 'rubygems'
gem 'soap4r'

RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "rspec", 
    :lib => false, 
    :version => "~> 1.2.9"
  config.gem "rspec-rails", 
    :lib => false, 
    :version => "~> 1.2.9"
  config.gem 'mocha'
  config.gem 'authlogic'
  config.gem "thoughtbot-factory_girl", 
    :lib => "factory_girl", 
    :source => "http://gems.github.com"
  config.gem 'mislav-will_paginate', 
    :version => '~> 2.3.8', 
    :lib => 'will_paginate', 
    :source => 'http://gems.github.com'
  config.gem 'haml', 
    :lib => 'haml', 
    :version => '>=2.2.0'
  config.gem 'chriseppstein-compass', 
    :lib => 'compass', 
    :source => 'http://gems.github.com'
  config.gem 'chriseppstein-compass-960-plugin', 
    :lib => 'ninesixty', 
    :source => 'http://gems.github.com'
  config.gem 'smurf', 
    :lib => 'smurf', 
    :source => 'http://gemcutter.org'

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
