require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts
  acts_as_authentic

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :country

  FREE = 0
  PLUS = 1
  POWER = 2

  PLANS = [ { :name => 'Free', :amount => 0, :fonts_allowed => 5, :requests_allowed => 5000 },
            { :name => 'Plus', :amount => 5, :fonts_allowed => 20, :requests_allowed => 20000 },
            { :name => 'Power', :amount => 15, :fonts_allowed => 100000, :requests_allowed => 50000 } ]

  before_validation_on_create :generate_oauth_token

  protected

  def generate_oauth_token
    self.oauth_token = ActiveSupport::SecureRandom.hex(12)
    self.oauth_secret = ActiveSupport::SecureRandom.hex(12)
  end
end
