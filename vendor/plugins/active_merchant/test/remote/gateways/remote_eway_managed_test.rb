require File.dirname(__FILE__) + '/../../test_helper'

class EwayManagedTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test

    @customer_id = 9876543211000
    
	  @gateway = EwayGateway.new(:login => 87654321, :username => 'test@eway.com.au', :password => "test123", :engine => :managed)


    @credit_card_success = credit_card('4444333322221111',
      :month => Time.now.month,
      :year => Time.now.year + 1
    )
    
    @credit_card_fail = credit_card('1234567812345678',
      :month => Time.now.month,
      :year => Time.now.year
    )
    
    @customer_params = {
      :order_id => '1230123',
      :email => 'bob@testbob.com',
      :title => 'Mr',
      :first_name => 'Bob',
      :last_name => 'Stewart',
      :address => '47 Bobway',
      :suburb => 'Bobville',
      :state => 'WA',
      :country => 'AU',
      :post_code => '2000',
      :phone_1 => '12341234',
      :phone_2 => '12341235',
      :fax => '12341236',
      :company => 'Bob Industries',
      :ref => 'Customer Reference',
      :job_desc => 'Job Description',
      :comments => 'Comments',
      :url => 'http://www.bob.com'
    }

    @payment_params = {
      :invoice_reference => 'Test Invoice',
      :invoice_description => 'Test Invoice Description'
    }
  end
  
  def test_create_customer
    customer = @gateway.create_customer(@credit_card_success, @customer_params)
    assert_not_nil customer.id
    assert_equal 112233445566, customer.id
  end

  def test_invalid_create_customer
    params = @customer_params.dup
    params[:first_name] = ''
    assert_raise SOAP::FaultError do
      response = @gateway.create_customer(@credit_card_success, params)
    end
  end

  def test_query_customer
    customer = @gateway.query_customer(@customer_id)
    assert("customer reference", customer.ref)
    assert("mr", customer.title)
    assert("firstname", customer.first_name)
    assert("lastname", customer.last_name)
    assert("company", customer.company)
    assert("job description", customer.job_description)
    assert("email", customer.email)
    assert("address", customer.address)
    assert("suburb", customer.suburb)
    assert("canberra", customer.state)
    assert("9999", customer.post_code)
    assert("1111111111", customer.phone_1)
    assert("2222222222", customer.phone_2)
    assert("fax", customer.fax)
    assert("ACT", customer.state)
    assert("country", customer.country)
    assert("http://www.eway.com.au", customer.url)
    assert("comments", customer.comments)
  end

  def test_query_non_existent_customer
    assert_nil @gateway.query_customer(111111)
  end

  def test_update_customer
    assert_equal true, @gateway.update_customer(@customer_id, @credit_card_success, @customer_params)
  end

  def test_invalid_update_customer
    params = @customer_params.dup
    params[:first_name] = ''

    assert_raise SOAP::FaultError do
      @gateway.update_customer(@customer_id, @credit_card_success, params)
    end
  end

  # Test Payments
  def test_process_payment
    response = @gateway.process_payment(100, @customer_id, @payment_params)
    assert_equal 10000, response.return_amount
    assert_equal "123456", response.auth_code
    assert_not_nil response.transaction_number
  end

  def test_process_invalid_payment
    assert_raise SOAP::FaultError do
      @gateway.process_payment(100, 123451234512344, @payment_params)
    end
  end

  def test_query_payment
    payments = @gateway.query_payment(@customer_id)
    assert_not_equal 0, payments.size
    assert_equal 'Approved', payments.first.response
    assert_equal 10, payments.first.amount
    assert_equal true, payments.first.success
    assert_equal 1, payments.first.transaction_number
    assert_not_nil payments.first.date
  end
end
