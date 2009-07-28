require 'soap/wsdlDriver' 
require 'soap/header/simplehandler'
require 'stringio'
require File.dirname(__FILE__) + '/base'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EwayRebill
      class ProxyBase < EwayBase::Proxy
        def wdsl
          "https://www.eway.com.au/gateway/rebill/test/managerebill_test.asmx?WSDL"
        end

        def header(eway_customer_id, username, password)
          EwayRebillHeader.new(eway_customer_id, username, password)
        end
      end
      
      # Add recurring billing - based on the Payflow API
      # See the EWay Managed reBILL Web Servicee for more details:
      #    
      # Several options are available to customize the recurring profile:
      #
      # * <tt>profile_id</tt> - is only required for editing a recurring profile
      # * <tt>starting_at</tt> - takes a Date, Time, or string in mmddyyyy format. The date must be in the future.
      # * <tt>ending_at</tt> - takes a Date, Time, or string in mmddyyyy format. The date must be in the future, after the starting_at date
      # * <tt>name</tt> - The name of the customer to be billed.  If not specified, the name from the credit card is used.
      # * <tt>periodicity</tt> - The frequency that the recurring payments will occur at.  Can be one of
      # :bimonthly, :monthly, :biweekly, :weekly, :yearly, :daily, :semimonthly, :quadweekly, :quarterly, :semiyearly
      # * <tt>payments</tt> - The term, or number of payments that will be made
      # * <tt>comment</tt> - A comment associated with the profile            
      def recurring(money, credit_card, options = {})
        # Step 1: Create a customer unless a customer_id is set
        unless options[:customer_id]
          customer_attributes = {}
          add_rebill_customer_data(customer_attributes, options)
          add_rebill_address_data(customer_attributes, options)
          
          customer = create_customer(customer_attributes)
          
          return customer if customer.error?
          options[:customer_id] = customer.customer.id
        end

        # Step 2: Create the Event
        event_attributes = {}
        event_attributes[:init_amt] = amount(money)
        event_attributes[:recur_amt] = amount(money)
        add_rebill_credit_card_data(event_attributes, credit_card)
        add_rebill_invoice_data(event_attributes, options)

        event = Event.new(event_attributes)
        event.create(@options[:login], @options[:username], @options[:password])
      end

      def change_recurring(money, credit_card, options = {})
        # Step 2: Create the Event
        event_attributes = {}
        event_attributes[:recur_amt] = amount(money)
        add_rebill_credit_card_data(event_attributes, credit_card)
        add_rebill_invoice_data(event_attributes, options)

        event = Event.new(event_attributes)
        event.update(@options[:login], @options[:username], @options[:password])
      end
      
      def cancel_recurring(profile_id, customer_id)
        Event.delete(profile_id, customer_id) 
      end
      
      def recurring_inquiry(profile_id, customer_id)
        Event.query(profile_id, customer_id) 
      end

      def query_customer(id)
        Customer.query(@options[:login], @options[:username], @options[:password], id)
      end

      def create_customer(options = {})
        customer = Customer.new(options)
        customer.create(@options[:login], @options[:username], @options[:password])
      end

      def update_customer(id, options = {})
        customer = Customer.new(options)
        customer.id = id
        customer.update(@options[:login], @options[:username], @options[:password])
      end

      def delete_customer(id)
        Customer.delete(@options[:login], @options[:username], @options[:password], id)
      end

      def create_event(options = {})
        event = Event.new(options)
        event.create(@options[:login], @options[:username], @options[:password])
      end

      def query_event(customer_id, id)
        Event.query(@options[:login], @options[:username], @options[:password], customer_id, id)
      end
      
      def update_event(id, options = {})
        event = Event.new(options)
        event.id = id
        event.update(@options[:login], @options[:username], @options[:password])
      end

      def delete_event(customer_id, id)
        Event.delete(@options[:login], @options[:username], @options[:password], customer_id, id)
      end

      class EwayRebillHeader < SOAP::Header::SimpleHandler
        def initialize(eway_customer_id, username, password)
          super(XSD::QName.new('http://www.eway.com.au/gateway/rebill/manageRebill', 'eWAYHeader'))
          @item = { :eWAYCustomerID => eway_customer_id, :Username => username, :Password => password }
        end

        def on_simple_outbound
          @item if @item
        end
      end
      
      class Customer < ProxyBase
        def initialize(attributes = {})
          self.fields = [ :id, :ref, :title, :first_name, :last_name, :company, :job_desc, :email, :address, :suburb, :state, :post_code, :country, :phone_1, :phone_2, :fax, :comments, :url ]
          super
        end

        def create(eway_customer_id, username, password)
          CustomerResponse.new(driver(eway_customer_id, username, password).CreateRebillCustomer(prepared_attributes).createRebillCustomerResult)
        end

        def update(eway_customer_id, username, password)
          CustomerResponse.new(driver(eway_customer_id, username, password).UpdateRebillCustomer(prepared_attributes).updateRebillCustomerResult)
        end

        def delete(eway_customer_id, username, password)
          CustomerResponse.new(driver(eway_customer_id, username, password).DeleteRebillCustomer(:RebillCustomerID => self.id).deleteRebillCustomerResult)
        end

        def self.delete(eway_customer_id, username, password, id)
          proxy = ProxyBase.new
          CustomerResponse.new(proxy.driver(eway_customer_id, username, password).DeleteRebillCustomer(:RebillCustomerID => id).deleteRebillCustomerResult)
        end
      
        def self.query(eway_customer_id, username, password, id)
          proxy = ProxyBase.new
          CustomerResponse.new(proxy.driver(eway_customer_id, username, password).QueryRebillCustomer(:RebillCustomerID => id).queryRebillCustomerResult)
        end
      
        def prepared_attributes(attributes = nil)
          attributes ||= @attributes
          tmp = {}
          self.fields.each do |key|
            case(key)
            when :url
              camel_key = "customerURL"
            when :id
              camel_key = "RebillCustomerID"
            else
              camel_key = "customer" + ProxyBase.camelize(key)
            end
            tmp[camel_key] = attributes.has_key?(key) && attributes[key] ? attributes[key] : ""
          end

          tmp
        end
      end

      class Event < ProxyBase
        def initialize(attributes = {})
          self.fields = [ :id, :customer_id, :inv_ref, :inv_des, :cc_name, :cc_number, :cc_exp_month, :cc_exp_year, :init_amt, :init_date, :recur_amt, :start_date, :interval, :interval_type, :end_date ]
          super
        end

        def create(eway_customer_id, username, password)
          EventResponse.new(driver(eway_customer_id, username, password).CreateRebillEvent(prepared_attributes).createRebillEventResult)
        end

        def update(eway_customer_id, username, password)
          EventResponse.new(driver(eway_customer_id, username, password).UpdateRebillEvent(prepared_attributes).updateRebillEventResult)
        end

        def delete(eway_customer_id, username, password)
          EventResponse.new(driver(eway_customer_id, username, password).DeleteRebillEvent(:RebillID => self.id).deleteRebillEventResult)
        end

        def self.delete(eway_customer_id, username, password, customer_id, id)
          proxy = ProxyBase.new
          EventResponse.new(proxy.driver(eway_customer_id, username, password).DeleteRebillEvent(:RebillCustomerID => customer_id, :RebillID => id).deleteRebillEventResult)
        end

        def self.query(eway_customer_id, username, password, customer_id, id)
          proxy = ProxyBase.new
          EventResponse.new(proxy.driver(eway_customer_id, username, password).queryRebillEvent(:RebillCustomerID => customer_id, :RebillID => id).queryRebillEventResult)
        end
        
        def prepared_attributes(attributes = nil)
          attributes ||= @attributes
          tmp = {}
          self.fields.each do |key|
            case(key)
            when :id
              camel_key = "RebillID"
            when :customer_id
              camel_key = "RebillCustomerID"
            when :cc_name
              camel_key = "RebillCCName"
            when :cc_number
              camel_key = "RebillCCNumber"
            when :cc_exp_month
              camel_key = "RebillCCExpMonth"
            when :cc_exp_year
              camel_key = "RebillCCExpYear"
            when :init_date
              camel_key = "RebillInitDate"
              attributes[key] = attributes[key].strftime("%d/%m/%Y") unless attributes[key] == nil
            when :start_date
              camel_key = "RebillStartDate"
              attributes[key] = attributes[key].strftime("%d/%m/%Y") unless attributes[key] == nil
            when :end_date
              camel_key = "RebillEndDate"
              attributes[key] = attributes[key].strftime("%d/%m/%Y") unless attributes[key] == nil
            when :interval_type
              camel_key = "RebillIntervalType"
              unless attributes[key] == nil
                case(attributes[key].to_sym)
                when(:daily)
                  attributes[key] = 1
                when(:weekly)
                  attributes[key] = 2
                when(:monthly)
                  attributes[key] = 3
                when(:yearly)
                  attributes[key] = 4
                end
              end
            else
              camel_key = "Rebill" + ProxyBase.camelize(key)
            end
            tmp[camel_key] = attributes.has_key?(key) && attributes[key] ? attributes[key] : ""
          end
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

      class EventResponse < EwayBase::Response
        attr_accessor :rebill_id, :customer_id, :event

        def initialize(soap_obj)
          super
          self.rebill_id = soap_obj.rebillID if soap_obj.respond_to?(:rebillID)
          self.customer_id = soap_obj.rebillCustomerID if soap_obj.respond_to?(:rebillCustomerID)

          # Try to fill the event object
          self.event = Event.new
          self.event.id = self.rebill_id

          self.event.fields.each do |key|
            case(key)
            when(:id)
              method = "rebillID"
            when(:customer_id)
              method = "rebillCustomerID"
            when(:inv_des)
              method = "rebillInvDesc"
            when(:cc_name)
              method = "rebillCCName"
            when(:cc_number)
              method = "rebillCCNumber"
            when(:cc_exp_month)
              method = "rebillCCExpMonth"
            when(:cc_exp_year)
              method = "rebillCCExpYear"
            else
              method = "rebill" + ProxyBase.camelize(key)
            end
            
            case(key)
            when(:start_date)
              self.event.start_date = DateTime.strptime(soap_obj.rebillStartDate, "%d/%m/%Y") if soap_obj.respond_to?(:rebillStartDate)
            when(:init_date)
              self.event.init_date = DateTime.strptime(soap_obj.rebillInitDate, "%d/%m/%Y") if soap_obj.respond_to?(:rebillInitDate)
            when(:end_date)
              self.event.end_date = DateTime.strptime(soap_obj.rebillEndDate, "%d/%m/%Y") if soap_obj.respond_to?(:rebillEndDate)
            when(:interval_type)
              if soap_obj.respond_to?(:rebillIntervalType)
                case(soap_obj.rebillIntervalType)
                when('1')
                  self.event.interval_type = :daily
                when('2')
                  self.event.interval_type = :weekly
                when('3')
                  self.event.interval_type = :monthly
                when('4')
                  self.event.interval_type = :yearly
                end
              end
            else
              self.event.send("#{key}=", soap_obj.send(method)) if soap_obj.respond_to?(method)
            end
          end

        end
      end

      def interval(interval)
        case(interval)
        when :daily
          return 1
        when :weekly
          return 1
        when :biweekly
          return 2
        when :quadweekly
          return 4
        when :monthly
          return 1
        when :bimonthly
          return 2
        when :quarterly
          return 3
        when :yearly
          return 1
        when :biyearly
          return 2
        end
      end

      def interval_type(interval)
        case(interval)
        when :daily
          return 1
        when :weekly, :biweekly, :quadweekly
          return 2
        when :monthly, :bimonthly, :quarterly
          return 3
        when :yearly, :biyearly
          return 4
        end
      end

      def add_rebill_credit_card_data(attributes, credit_card)
        attributes[:cc_number] = credit_card.number
        attributes[:cc_name] = credit_card.first_name + " " + credit_card.last_name
        attributes[:cc_exp_month] = credit_card.month
        attributes[:cc_exp_year] = credit_card.year
      end

      def add_rebill_customer_data(attributes, options)
        attributes[:first_name] = options[:first_name]
        attributes[:last_name] = options[:last_name]
        attributes[:email] = options[:email]

        if options[:customer]
          attributes[:ref] = options[:customer][:ref]
          attributes[:title] = options[:customer][:title]
          attributes[:company] = options[:customer][:company]
          attributes[:job_desc] = options[:customer][:job_desc]
          attributes[:phone_1] = options[:customer][:phone_1]
          attributes[:phone_2] = options[:customer][:phone_2]
          attributes[:fax] = options[:customer][:fax]
          attributes[:url] = options[:customer][:url]
          attributes[:comments] = options[:customer][:comments]
        end
      end

      def add_rebill_invoice_data(attributes, options)
        attributes[:customer_id] = options[:customer_id]
        attributes[:interval] = interval(options[:periodicity])
        attributes[:interval_type] = interval_type(options[:periodicity])
        attributes[:start_date] = options[:starting_at]
        attributes[:end_date] = options[:ending_at]
      end

      def add_rebill_address_data(attributes, options)
        attributes[:address] = options[:billing_address][:address1]
        attributes[:suburb] = options[:billing_address][:suburb]
        attributes[:state] = options[:billing_address][:state]
        attributes[:country] = options[:billing_address][:country]
        attributes[:post_code] = options[:billing_address][:zip]
      end
    end
  end
end
