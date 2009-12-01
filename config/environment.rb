require 'rubygems'
gem 'soap4r'

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'mysql'
  config.gem "rspec", 
    :lib => false, 
    :version => ">= 1.2.0"
  config.gem "rspec-rails", 
    :lib => false, 
    :version => ">= 1.2.0"
  config.gem 'mocha'
  config.gem 'authlogic'
  config.gem 'oauth'
  config.gem "thoughtbot-factory_girl", 
    :lib => "factory_girl", 
    :source => "http://gems.github.com"
  config.gem 'mislav-will_paginate', 
    :version => '~> 2.3.8', 
    :lib => 'will_paginate', 
    :source => 'http://gems.github.com'
  config.gem 'money'
  config.gem 'soap4r'


  config.action_controller.session_store = :active_record_store

  config.time_zone = 'UTC'

  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "typefront.com",
    :authentication => :plain,
    :user_name => "contact@typefront.com",
    :password => "2001gattaca"
  }
end

Mime::Type.register 'application/x-font', :font

COUNTRIES_JSON = "#{RAILS_ROOT}/config/reference_data/countries.json"
