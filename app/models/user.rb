require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts, :dependent => :destroy
  acts_as_authentic

  SUPPORTED_CARDS = { :visa => 'Visa',
                      :master => 'Mastercard' }

  attr_accessor :card_number, :card_cvv, :terms

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :postcode, :country, :card_type, :card_name, :card_number,
    :card_cvv, :card_expiry, :unless => :on_free_plan?
  validates_acceptance_of :terms, 
    :message => 'must be accepted before you can create an account'
  validates_inclusion_of :card_type, :in => SUPPORTED_CARDS.keys.collect { |x| x.to_s }

  validate_on_create :validate_card

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

  protected

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type => card_type,
      :number => card_number,
      :verification_value => card_cvv,
      :month => card_expiry ? card_expiry.month : nil,
      :year => card_expiry ? card_expiry.year : nil,
      :first_name => first_name,
      :last_name => last_name
    )
  end
end
