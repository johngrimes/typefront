require 'soap/wsdlDriver' 
require 'soap/header/simplehandler'
require 'stringio'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EwayBase
      class Response
        attr_accessor :result, :error_severity, :error_details

        def initialize(soap_obj)
          self.result = soap_obj.result
          self.error_severity = soap_obj.errorSeverity
          self.error_details = soap_obj.errorDetails
        end

        def success?
          return self.error_severity.nil? && self.error_details.nil?
        end

        def error?
          return !self.success?
        end
      end

      class Proxy
        attr_accessor :attributes, :fields
        include Validateable

        def initialize(attributes = {})
          self.fields ||= []
          self.attributes = attributes
        end
        
        def id=(id)
          self.attributes[:id] = id
        end

        def id
          return self.attributes[:id]
        end
       
        def wdsl
          ""
        end

        def header(eway_customer_id, username, password)
          nil
        end

        def driver(eway_customer_id, username, password)
          @driver ||= SOAP::WSDLDriverFactory.new(wdsl).create_rpc_driver
          @driver.default_encodingstyle = SOAP::EncodingStyle::ASPDotNetHandler.new
          #@driver.wiredump_dev = STDERR
          @driver.generate_explicit_type = true
          @driver.headerhandler << header(eway_customer_id, username, password)
          @driver
        end

        def attributes=(attributes)
          @attributes ||= {}
          attributes.each { |key, value| @attributes[key.to_sym] = value if self.fields.include?(key.to_sym) }
        end

        def attributes
          @attributes
        end

        def method_missing(method_id, *params)
          return @attributes[method_id.id2name[0..-2].to_sym] = params[0] if method_id.id2name.last == "=" && self.fields.include?(method_id.id2name[0..-2].to_sym)
          return @attributes[method_id.id2name.to_sym] if self.fields.include?(method_id.id2name.to_sym)
        end

        def self.underscore(camel_cased_word)
          camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        end

        def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
          if first_letter_in_uppercase
            lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
          else
            lower_case_and_underscored_word.to_s.first + camelize(lower_case_and_underscored_word)[1..-1]
          end
        end

      end
    end
  end
end
