require 'active_support/secure_random'
require 'credit_card_validator'

class User < ActiveRecord::Base
  has_many :fonts, :dependent => :destroy
  has_many :ready_fonts, 
    :class_name => 'Font',
    :conditions => { :generate_jobs_pending => 0 }
  has_many :font_formats, :through => :fonts
  has_many :invoices
  acts_as_authentic do |c|
    c.perishable_token_valid_for = 48.hours
    c.disable_perishable_token_maintenance = true
  end

  FREE = 0
  PLUS = 1
  POWER = 2

  PLANS = [ { :name => 'Free', :amount => 0, :fonts_allowed => 1, :requests_allowed => 500 },
            { :name => 'Plus', :amount => 5, :fonts_allowed => 10, :requests_allowed => 5000 },
            { :name => 'Power', :amount => 15, :fonts_allowed => 100000, :requests_allowed => 20000 } ]

  SUPPORTED_CARDS = { :visa => 'Visa',
                      :master => 'Mastercard',
                      :american_express => 'American Express',
                      :jcb => 'JCB' }

  FREE_TRIAL_PERIOD = 30.days
  BILLING_PERIOD = 1.month
  AUTOMATIC_BILLING_WINDOW = 7.days
  PAYMENT_STRIKES = 3

  TEST_CUSTOMER_ID = 9876543211000

  attr_accessible :email, :password, :password_confirmation, :address_1,
    :address_2, :city, :state, :postcode, :country, :first_name,
    :last_name, :company_name, :subscription_level, :card_name,
    :card_type, :card_number, :card_cvv, :card_expiry, :terms

  attr_accessor :card_number, :card_cvv, :terms
  attr_accessor_with_default :card_validation_on, false

  validates_presence_of :first_name, :last_name, :address_1, :city,
    :state, :postcode, :country, :card_type, :card_name, :card_expiry,
    :unless => :on_free_plan?
  validates_presence_of :card_number, :card_cvv, :if => :card_validation_on, :unless => :on_free_plan?
  validates_length_of :email, :address_1, :address_2, :city, :state,
    :first_name, :last_name, :company_name, :maximum => 255, :allow_nil => true
  validates_acceptance_of :terms, 
    :message => 'must be accepted before you can create an account', :allow_nil => false, :on => :create
  validates_inclusion_of :card_type, :in => SUPPORTED_CARDS.keys.collect { |x| x.to_s }, :if => :card_validation_on, :unless => :on_free_plan?

  validate_on_create :validate_card, :if => :card_validation_on, :unless => :on_free_plan?

  before_save :populate_subscription_fields, :populate_masked_card_number
  after_create :create_gateway_customer, :process_billing, :unless => :on_free_plan?
  after_destroy :destroy_billing_jobs

  def full_name
    unless first_name.blank? && last_name.blank?
      "#{first_name} #{last_name}"
    else
      ''
    end
  end

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

  def User.gateway
    @@gateway ||= BigCharger.new(
      GATEWAY_CONFIG[:customer_id], 
      GATEWAY_CONFIG[:username], 
      GATEWAY_CONFIG[:password],
      GATEWAY_CONFIG[:test_mode] ? true : false,
      Rails.logger
    )
  end

  def gateway_customer_fields
    address = []
    address.push(address_1) unless address_1.blank?
    address.push(address_2) unless address_2.blank?
    country_file = IO.read(COUNTRIES_JSON)
    countries = ActiveSupport::JSON.decode(country_file)
    country_code = countries.select { |x| x['name'] == country }.first
    country_code = country_code['code'].downcase

    customer_fields = {
      'CustomerRef' => id,
      'FirstName' => first_name,
      'LastName' => last_name,
      'Email' => email,
      'Address' => address.join(', '),
      'Suburb' => city,
      'State' => state,
      'Country' => country_code,
      'PostCode' => postcode,
      'Company' => company_name,
      'CCNameOnCard' => card_name,
      'CCNumber' => card_number,
      'CCExpiryMonth' => card_expiry ? card_expiry.month : nil,
      'CCExpiryYear' => card_expiry ? card_expiry.year.to_s[2..3] : nil,
      # All fields must have something in them:
      'Title' => 'Mr.',
      'Fax' => '',
      'Phone' => '',
      'Mobile' => '',
      'JobDesc' => '',
      'Comments' => '',
      'URL' => ''
    }
  end

  def create_gateway_customer
    unless on_free_plan?
      response = User.gateway.create_customer(gateway_customer_fields)
      raise Exception, "Customer ID not returned when attempting to create new gateway customer." if response.blank?

      response = TEST_CUSTOMER_ID if RAILS_ENV != 'production'

      update_attribute(:gateway_customer_id, response.to_i)
    end
  end

  def update_gateway_customer
    unless on_free_plan?
      if gateway_customer_id.blank?
        create_gateway_customer
      else
        response = User.gateway.update_customer(gateway_customer_id, gateway_customer_fields)
        raise Exception, "Response not successful when attempting to update gateway customer." if !response
      end
    end
  end

  def process_billing(options = {})
    unless on_free_plan?
      now = Time.now

      if subscription_renewal.blank?
        if options[:skip_trial_period]
          bill_for_one_period(now, BILLING_PERIOD.since(now))
          update_attribute(:subscription_renewal, BILLING_PERIOD.since(now))
        else
          update_attribute(:subscription_renewal, FREE_TRIAL_PERIOD.since(now))
        end
        Resque.enqueue_at(subscription_renewal, BillingJob, :user_id => id)

      elsif subscription_renewal <= now && (now - subscription_renewal) <= AUTOMATIC_BILLING_WINDOW
        bill_for_one_period(subscription_renewal, BILLING_PERIOD.since(subscription_renewal))
        update_attribute(:subscription_renewal, BILLING_PERIOD.since(subscription_renewal))
        Resque.enqueue_at(subscription_renewal, BillingJob, :user_id => id)

      elsif subscription_renewal <= now && (now - subscription_renewal) > AUTOMATIC_BILLING_WINDOW
        AdminMailer.deliver_billing_job_missed_window(self)
      end
    end
  end

  def bill_for_one_period(from_date, to_date, amount = subscription_amount)
    invoice = Invoice.new(
      :user_id => id,
      :amount => amount,
      :description => "Payment for TypeFront #{subscription_name} subscription from #{from_date} to #{to_date}")
    invoice.save!

    response = User.gateway.process_payment(gateway_customer_id, amount * 100, invoice.id, invoice.description)

    if response['ewayTrxnStatus'] == 'True'
      unless response['ewayReturnAmount'].to_i == (invoice.amount * 100)
        raise Exception, "Received payment response from gateway with different amount (#{response['ewayReturnAmount']}) to invoice amount (#{invoice.amount * 100})."
      end

      invoice.paid_at = Time.now
      invoice.auth_code = response['ewayAuthCode']
      invoice.gateway_txn_id = response['ewayTrxnNumber']
      invoice.error_message = response['ewayTrxnError']
      invoice.save!
      self.payment_fail_count = 0
      save!
      UserMailer.deliver_receipt(invoice)
      AdminMailer.deliver_payment_received(invoice)
    else
      invoice.gateway_txn_id = response['ewayTrxnNumber']
      invoice.error_message = response['ewayTrxnError']
      invoice.save!
      self.payment_fail_count += 1
      save!
      handle_failed_payment(invoice)
    end
  end

  def handle_failed_payment(invoice)
      AdminMailer.deliver_payment_failed(invoice)
      if payment_fail_count < PAYMENT_STRIKES
        UserMailer.deliver_payment_failed(invoice)
        Resque.enqueue_at(24.hours.from_now, BillingJob, :user_id => id)
      else
        self.subscription_level = 0
        self.payment_fail_count = 0
        populate_subscription_fields
        save!
        clear_all_billing
        clip_fonts_to_plan_limit
        UserMailer.deliver_account_downgraded(invoice)
      end
  end

  def clear_all_billing
    destroy_billing_jobs
    self.card_name, self.card_type, self.card_expiry,
      self.subscription_renewal, self.gateway_customer_id = nil
    save!
  end

  def destroy_billing_jobs
    Resque.remove_delayed(BillingJob, :user_id => id)
  end

  def reset_subscription_renewal(date)
    update_attribute(:subscription_renewal, date)
    Resque.enqueue_at(subscription_renewal, BillingJob, :user_id => id)
  end

  def clip_fonts_to_plan_limit
    number_to_clip = fonts.count - fonts_allowed
    if number_to_clip > 0
      clipped = fonts.find(:all, :order => 'created_at ASC', :limit => number_to_clip)
      clipped.each do |font|
        font.destroy
      end
    end
  end
  
  protected

  def validate_card
    unless card_number && CreditCardValidator::Validator.valid?(card_number)
      errors.add :card_number, 'is not a valid card number'
    end
  end
end
