ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'test_help'
require 'spec/autorun'
require 'spec/rails'
require 'authlogic/test_case'

Spec::Runner.configure do |config|
  config.global_fixtures = :all
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.mock_with :mocha
  config.include BeValidAsset
end

if ENV['TEST_XHTML'] && ENV['TEST_XHTML'] == 'false'
  puts 'XHTML validation is turned OFF.'
  module BeValidAsset
    def be_valid_xhtml
    end
  end
end

alias :doing :lambda

def login(user)
  activate_authlogic
  UserSession.create(user)
end

def logout
  activate_authlogic
  @session = UserSession.find
  if @session
    @session.destroy
  end
end

def random_string(length = 8)
  chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
  string = ''
  length.times { |i| string << chars[rand(chars.length)] }
  return string
end
