require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts
  acts_as_authentic

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :country

  BASIC = 1
  PLUS = 2
  POWER = 3
  BUSINESS = 4

  before_validation_on_create :generate_oauth_token

  protected

  def generate_oauth_token
    self.oauth_token = ActiveSupport::SecureRandom.hex(12)
    self.oauth_secret = ActiveSupport::SecureRandom.hex(12)
  end
end
