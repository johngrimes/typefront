require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts, :dependent => :destroy
  acts_as_authentic

  attr_accessor :card_number, :card_cvv, :terms

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :postcode, :country, :card_type, :card_name, :card_number,
    :card_cvv, :card_expiry, :unless => :on_free_plan?
  validates_acceptance_of :terms, 
    :message => 'must be accepted before you can create an account'
  validates_inclusion_of :card_type, :in => ['Visa', 'Mastercard', 'American Express']

  FREE = 0
  PLUS = 1
  POWER = 2

  PLANS = [ { :name => 'Free', :amount => 0, :fonts_allowed => 5, :requests_allowed => 5000 },
            { :name => 'Plus', :amount => 5, :fonts_allowed => 20, :requests_allowed => 20000 },
            { :name => 'Power', :amount => 15, :fonts_allowed => 100000, :requests_allowed => 50000 } ]

  before_save :populate_subscription_fields

  def populate_subscription_fields
    if !self.subscription_level.blank?
      self.subscription_name = PLANS[self.subscription_level][:name]
      self.subscription_amount = PLANS[self.subscription_level][:amount]
      self.fonts_allowed = PLANS[self.subscription_level][:fonts_allowed]
      self.requests_allowed = PLANS[self.subscription_level][:requests_allowed]
    end
  end
  
  def active?
    active
  end

  def on_free_plan?
    self.subscription_level == 0 ? true : false
  end
end
