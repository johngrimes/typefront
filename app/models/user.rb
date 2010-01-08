require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts, :dependent => :destroy
  has_many :invoices
  acts_as_authentic

  SUPPORTED_CARDS = { :visa => 'Visa',
                      :master => 'Mastercard' }

  FREE_TRIAL_PERIOD = 1.minute
  BILLING_PERIOD = 2.minutes

  TEST_CUSTOMER_ID = 9876543211000

  attr_accessor :card_number, :card_cvv, :terms

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :postcode, :country, :card_type, :card_name, :card_expiry,
    :unless => :on_free_plan?
  validates_presence_of :card_number, :card_cvv, :on => :create
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
  after_create :create_gateway_customer, :process_billing

  def active?
    active
  end

  def on_free_plan?
    self.subscription_level == 0 ? true : false
  end

  def populate_subscription_fields
    if !self.subscription_level.blank?
      self.subscription_name = PLANS[self.subscription_level][:name]
      self.subscription_amount = PLANS[self.subscription_level][:amount]
      self.fonts_allowed = PLANS[self.subscription_level][:fonts_allowed]
      self.requests_allowed = PLANS[self.subscription_level][:requests_allowed]
    end
  end

  def create_gateway_customer
    unless on_free_plan?
      address = []
      address.push(address_1) unless address_1.blank?
      address.push(address_2) unless address_2.blank?
      country_file = IO.read(COUNTRIES_JSON)
      countries = ActiveSupport::JSON.decode(country_file)
      country_code = countries.select { |x| x['name'] == country }.first

      customer_fields = {
        :ref => id,
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :address => address.join(', '),
        :suburb => city,
        :state => state,
        :country => country_code,
        :post_code => postcode,
        :company => company_name,
      }

      response = ::GATEWAY.create_customer(credit_card, customer_fields)
      raise Exception, "Customer ID not returned when attempting to create new gateway customer." if response.id.blank?

      response.id = TEST_CUSTOMER_ID if RAILS_ENV != 'production'

      update_attributes!(:gateway_customer_id => response.id)
    end
  end

  def process_billing
    unless on_free_plan?
      now = Time.now
      if subscription_renewal.blank?
        update_attributes!(:subscription_renewal => FREE_TRIAL_PERIOD.since(now))
        Delayed::Job.enqueue ProcessBillingJob.new(id), 0, subscription_renewal
      elsif subscription_renewal <= now
        bill_for_one_period
        update_attributes!(:subscription_renewal => BILLING_PERIOD.since(subscription_renewal))
        Delayed::Job.enqueue ProcessBillingJob.new(id), 0, subscription_renewal
      end
    end
  end

  def bill_for_one_period
    invoice = Invoice.new(
      :user_id => id,
      :amount => subscription_amount,
      :description => "Recurring payment for TypeFront #{subscription_name} subscription")
    invoice.save!

    response = ::GATEWAY.process_payment(
      subscription_amount,
      gateway_customer_id,
      :invoice_reference => invoice.id,
      :invoice_description => invoice.description)

    if response.status
      unless response.return_amount == (invoice.amount * 100)
        raise Exception, 'Received payment response from gateway with different amount to invoice amount.'
      end

      invoice.update_attributes!(
        :paid_at => Time.now,
        :auth_code => response.auth_code,
        :gateway_txn_id => response.transaction_number,
        :error_message => response.error
      )
    else
      invoice.update_attributes!(
        :gateway_txn_id => response.transaction_number,
        :error_message => response.error
      )
    end
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
