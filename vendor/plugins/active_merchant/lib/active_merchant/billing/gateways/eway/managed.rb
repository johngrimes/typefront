require 'soap/wsdlDriver' 
require 'soap/header/simplehandler'
require 'stringio'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EwayManaged
      class ProxyBase < EwayBase::Proxy
        def wdsl
          "https://www.eway.com.au/gateway/ManagedPaymentService/test/managedCreditCardPayment.asmx?WSDL"
        end

        def header(eway_customer_id, username, password)
          EwayManagedHeader.new(eway_customer_id, username, password)
        end
      end
 
      class EwayManagedHeader < SOAP::Header::SimpleHandler
        def initialize(eway_customer_id, username, password)
          super(XSD::QName.new('https://www.eway.com.au/gateway/managedpayment', 'eWAYHeader'))
          @item = { :eWAYCustomerID => eway_customer_id, :Username => username, :Password => password }
        end

        def on_simple_outbound
          @item if @item
        end
      end

      class Customer < ProxyBase
        attr_accessor :options

        def initialize(attributes = {}, options = {})
          self.fields = [ :id, :ref, :title, :first_name, :last_name, :company, :job_desc, :email, :address, :suburb, :state, :post_code, :country, :phone, :mobile, :fax, :url, :comments ]
          self.options = options
          super(attributes)
        end

        def credit_card
          @credit_card
        end

        def credit_card=(credit_card)
          @credit_card = credit_card
        end

        def save(options = {})
           if id
            update(options)
          else
            create(options)
          end
          return true
        rescue
          return false
        end

        def save!(options = {})
          if id
            update(options)
          else
            create(options)
          end
        end

        def create(options = {})
          self.credit_card.require_verification_value = false
          raise ActiveRecord::RecordInvalid.new(self) unless self.valid?
          raise ActiveRecord::RecordInvalid.new(self.credit_card) unless self.credit_card.valid?
          self.credit_card.year = self.credit_card.year.to_s[2..3]

          options = self.options.merge(options)
          res = driver(options[:login], options[:username], options[:password]).CreateCustomer(prepared_attributes).createCustomerResult
          self.id = res.to_i
        end

        def update(options = {})
          self.credit_card.require_verification_value = false
          raise ActiveRecord::RecordInvalid.new(self) unless self.valid?
          raise ActiveRecord::RecordInvalid.new(self.credit_card) unless self.credit_card.valid?
          self.credit_card.year = self.credit_card.year.to_s[2..3]
          
          options = self.options.merge(options)
          res = driver(options[:login], options[:username], options[:password]).UpdateCustomer(prepared_attributes).updateCustomerResult
          return res == "true"
        end

        def self.query(id, options = {})
          proxy = ProxyBase.new
          response = proxy.driver(options[:login], options[:username], options[:password]).QueryCustomer(:managedCustomerID => id).queryCustomerResult
           
          customer = Customer.new({}, options)
          
          customer.fields.each do |field|
            case(field)
            when :id
              camel_key = "managedCustomerID"
            when :url
              camel_key = "customerURL"
            when :phone
              camel_key = "customerPhone1"
            when :mobile
              camel_key = "customerPhone2"
            else
              camel_key = "customer" + ProxyBase.camelize(field)
            end
            customer.send("#{field.to_s}=", response.send(camel_key))
          end

          ccName = response.cCName.split(' ')
          customer.credit_card = ActiveMerchant::Billing::CreditCard.new(
            :number => response.cCNumber,
            :month => response.cCExpiryMonth,
            :year => response.cCExpiryYear,
            :first_name => ccName.shift,
            :last_name => ccName.join(' ')
          )

          customer
        end
        
        def validate
          errors.add :first_name, 'is required' if self.first_name.blank?
          errors.add :last_name, 'is required' if self.last_name.blank?
          errors.add :email, 'is required' if self.email.blank?
        end

        def prepared_attributes(attributes = nil)
          attributes ||= @attributes
          tmp = {}
          self.fields.each do |key|
            case(key)
            when :id
              camel_key = "managedCustomerID"
            when :ref
              camel_key = "CustomerRef"
            when :url
              camel_key = "URL"
            else
              camel_key = ProxyBase.camelize(key)
            end
            
            tmp[camel_key.to_s] = attributes[key].to_s
          end
          tmp["Title"] = "Mr."
          tmp["Country"] = "au"
          
          # Now go through the Credit Card object
          tmp['CCNumber'] = self.credit_card.number
          tmp['CCNameOnCard'] = self.credit_card.first_name + " " + self.credit_card.last_name
          tmp['CCExpiryMonth'] = self.credit_card.month
          tmp['CCExpiryYear'] = self.credit_card.year
          
          tmp
        end
      end

      class CustomerResponse < EwayBase::Response
        attr_accessor :customer_id, :customer

        def initialize(soap_obj)
          super
          self.customer_id = soap_obj.rebillCustomerID == "0" ? nil : soap_obj.rebillCustomerID
          
          # Try to fill the customer object
          self.customer = Customer.new
          self.customer.id = self.customer_id

          self.customer.fields.each do |key|
            case(key)
            when(:url)
              method = "customerURL"
            else
              method = "customer" + ProxyBase.camelize(key)
            end

            self.customer.send("#{key}=", soap_obj.send(method)) if soap_obj.respond_to?(method)
          end
        end
      end

      class Payment < ProxyBase
        def initialize(attributes = {})
          self.fields = [ :id, :customer_id, :amount, :invoice_reference, :invoice_description ]
          super
        end

        def self.query(customer_id, options = {})
          proxy = ProxyBase.new
          res = proxy.driver(options[:login], options[:username], options[:password]).QueryPayment(:managedCustomerID => customer_id).queryPaymentResult
          payments = []
          res.managedTransaction.each do |t|
            payments << PaymentQueryResponse.new(t)
          end
          payments
        end

        def query(options = {})
          Payment.query(self.customer_id)
        end
      
        def process(options = {})
          begin
            res = driver(options[:login], options[:username], options[:password]).ProcessPayment(prepared_attributes).ewayResponse
            return PaymentResponse.new(res)
          rescue SOAP::FaultError => message
            response = EwayManaged::PaymentResponse.new
            response.status = false
            response.error = message
            response.return_amount = self.amount
            return response
          end
        end

        def prepared_attributes(attributes = nil)
          attributes ||= @attributes
          tmp = {}
          self.fields.each do |key|
            case(key)
            when :customer_id
              camel_key = "managedCustomerID"
            else
              camel_key = ProxyBase.camelize(key, false)
            end
            tmp[camel_key] = attributes[key]
          end

          tmp
        end

        def validate
          errors.add :customer_id, 'is required' if self.customer_id.blank?
          errors.add :amount, 'is required' if self.amount.blank?
          errors.add :invoice_reference, 'is required' if self.invoice_reference.blank?
          errors.add :amount, 'must be a number' unless self.amount.is_a(Number) 
        end
      end

      class PaymentResponse < EwayBase::Response
        attr_accessor :status, :transaction_number, :return_amount, :auth_code, :error

        def initialize(soap_obj = nil)
          if soap_obj
            self.status = soap_obj.ewayTrxnStatus == "True"
            self.transaction_number = soap_obj.ewayTrxnNumber.to_i
            self.return_amount = soap_obj.ewayReturnAmount.to_i
            self.auth_code = soap_obj.ewayAuthCode
            self.error = soap_obj.ewayTrxnError
          end
        end
      end

      class PaymentQueryResponse < EwayBase::Response
        attr_accessor :amount, :success, :response, :date, :transaction_number

        def initialize(soap_obj = nil)
          if soap_obj
            self.amount = soap_obj.totalAmount.to_i.to_f / 100
            self.success = soap_obj.result == "1"
            self.response = soap_obj.responseText
            self.date = DateTime.strptime(soap_obj.transactionDate, "%Y-%m-%dT%H:%M:%S%Z")
            self.transaction_number = soap_obj.ewayTrxnNumber.to_i
          end
        end
      end
    end
  end
end
