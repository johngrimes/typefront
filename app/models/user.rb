require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts

  acts_as_authentic

  before_validation_on_create :generate_oauth_token

  protected

  def generate_oauth_token
    self.oauth_token = SecureRandom.hex(12)
    self.oauth_secret = SecureRandom.hex(12)
  end
end
