require File.dirname(__FILE__) + '/../../test_helper'

class PaypalCommonApiTest < Test::Unit::TestCase
  # build_refund
  class MockPaypalGateway
    class << self
      attr_accessor :default_currency

      def publicize_methods
        saved_private_instance_methods = self.private_instance_methods
        self.class_eval { public *saved_private_instance_methods }
        yield
        self.class_eval { private *saved_private_instance_methods }
      end
    end

    include ActiveMerchant::Billing::PaypalCommonAPI

    def initialize
    end

    def amount(value)
      value
    end

    def currency(value)
      'USD'
    end
  end

  def setup
    @gateway = MockPaypalGateway.new
  end

  def test_build_credit_request_defaults_refund_type_to_partial
    MockPaypalGateway.publicize_methods do
      assert_xpath_content(
        "/RefundTransactionReq/RefundTransactionRequest/RefundType", 
        "Partial",
        @gateway.build_credit_request(100, 'TXID', {})
      )
    end
  end

  def test_build_credit_request_allows_a_full_refund_override
    MockPaypalGateway.publicize_methods do
      assert_xpath_content(
        "/RefundTransactionReq/RefundTransactionRequest/RefundType", 
        "Full", 
        @gateway.build_credit_request(100, 'TXID', {:type => 'Full'})
      )
    end
  end

  private

  def assert_xpath_content(xpath, text, doc)
    doc = doc.is_a?(REXML::Document) ? doc : REXML::Document.new(doc)  
    match = REXML::XPath.match doc, xpath  
    assert !match.empty?, "Missing xpath '#{xpath}' in document: #{doc}"  
    assert match.any? {|x| x.text == text }, "No element contains text '#{text}'"
  end
end
