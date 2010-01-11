require 'active_support/secure_random'

class User < ActiveRecord::Base
  has_many :fonts, :dependent => :destroy
  has_many :invoices
  acts_as_authentic

  FREE = 0
  PLUS = 1
  POWER = 2

  PLANS = [ { :name => 'Free', :amount => 0, :fonts_allowed => 5, :requests_allowed => 5000 },
            { :name => 'Plus', :amount => 5, :fonts_allowed => 20, :requests_allowed => 20000 },
            { :name => 'Power', :amount => 15, :fonts_allowed => 100000, :requests_allowed => 50000 } ]

  SUPPORTED_CARDS = { :visa => 'Visa',
                      :master => 'Mastercard' }

  FREE_TRIAL_PERIOD = 30.days
  BILLING_PERIOD = 1.month
  AUTOMATIC_BILLING_WINDOW = 7.days

  TEST_CUSTOMER_ID = 9876543211000

  attr_accessor :card_number, :card_cvv, :terms
  attr_accessor_with_default :card_validation_on, false

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :postcode, :country, :card_type, :card_name, :card_expiry,
    :unless => :on_free_plan?
  validates_presence_of :card_number, :card_cvv, :if => :card_validation_on
  validates_acceptance_of :terms, 
    :message => 'must be accepted before you can create an account', :on => :create
  validates_inclusion_of :card_type, :in => SUPPORTED_CARDS.keys.collect { |x| x.to_s }, :if => :card_validation_on

  validate_on_create :validate_card, :if => :card_validation_on

  before_save :populate_subscription_fields, :populate_masked_card_number
  after_create :create_gateway_customer, :process_billing
  after_update :update_gateway_customer, :if => :card_validation_on

  def active?
    active
  end

  def on_free_plan?
    self.subscription_level == 0 ? true : false
  end

  def populate_subscription_fields
    if !subscription_level.blank?
      self.subscription_name = PLANS[self.subscription_level][:name]
      self.subscription_amount = PLANS[self.subscription_level][:amount]
      self.fonts_allowed = PLANS[self.subscription_level][:fonts_allowed]
      self.requests_allowed = PLANS[self.subscription_level][:requests_allowed]
    end
  end

  def populate_masked_card_number
    if !card_number.blank?
      self.masked_card_number = card_number.sub((part = card_number[1..-5]), 'x' * part.length)
    end
  end

  def gateway_customer_fields
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
      :company => company_name
    }
  end

  def create_gateway_customer
    unless on_free_plan?
      response = ::GATEWAY.create_customer(credit_card, gateway_customer_fields)
      raise Exception, "Customer ID not returned when attempting to create new gateway customer." if response.id.blank?

      response.id = TEST_CUSTOMER_ID if RAILS_ENV != 'production'

      update_attributes!(:gateway_customer_id => response.id)
    end
  end

  def update_gateway_customer
    unless on_free_plan?
      logger.info gateway_customer_fields.inspect
      response = ::GATEWAY.update_customer(gateway_customer_id, credit_card, gateway_customer_fields)
      raise Exception, "Response not successful when attempting to update gateway customer." if !response
    end
  end

  def process_billing
    unless on_free_plan?
      now = Time.now

      if subscription_renewal.blank?
        update_attributes!(:subscription_renewal => FREE_TRIAL_PERIOD.since(now))
        Delayed::Job.enqueue ProcessBillingJob.new(id), 0, subscription_renewal

      elsif subscription_renewal <= now && (now - subscription_renewal) <= AUTOMATIC_BILLING_WINDOW
        bill_for_one_period(subscription_renewal, BILLING_PERIOD.since(subscription_renewal))
        update_attributes!(:subscription_renewal => BILLING_PERIOD.since(subscription_renewal))
        Delayed::Job.enqueue ProcessBillingJob.new(id), 0, subscription_renewal

      elsif subscription_renewal <= now && (now - subscription_renewal) > AUTOMATIC_BILLING_WINDOW
        AdminMailer.deliver_billing_job_missed_window(self)
      end
    end
  end

  def bill_for_one_period(from_date, to_date)
    invoice = Invoice.new(
      :user_id => id,
      :amount => subscription_amount,
      :description => "Payment for TypeFront #{subscription_name} subscription from #{from_date} to #{to_date}")
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
      UserMailer.deliver_receipt(invoice)
    else
      invoice.update_attributes!(
        :gateway_txn_id => response.transaction_number,
        :error_message => response.error
      )
    end
  end

  def reset_subscription_renewal(date)
    update_attributes!(:subscription_renewal => date)
    Delayed::Job.enqueue ProcessBillingJob.new(id), 0, subscription_renewal
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
