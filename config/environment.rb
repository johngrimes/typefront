RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'mysql'
  config.gem "rspec", :lib => false, :version => ">= 1.2.0"
  config.gem "rspec-rails", :lib => false, :version => ">= 1.2.0"
  config.gem 'mocha'
  config.gem 'authlogic'
  config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"

  config.action_controller.session_store = :active_record_store

  config.time_zone = 'UTC'
end

Mime::Type.register 'application/x-font', :font
