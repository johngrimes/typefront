require File.dirname(__FILE__) + '/../../test_helper'

class EwayRebillTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test
    @gateway = EwayGateway.new(fixtures(:eway_rebill))

    @credit_card_success = credit_card('4444333322221111')
    
    @credit_card_fail = credit_card('1234567812345678',
      :month => Time.now.month,
      :year => Time.now.year
    )
    
    @recurring_params = {
      :order_id => '1230123',
      :email => 'bob@testbob.com',
      :first_name => 'Bob',
      :last_name => 'Stewart',
      
      :customer => {} ,
      :billing_address => { :address1 => '47 Bobway',
                            :city => 'Bobville',
                            :state => 'WA',
                            :country => 'AU',
                            :zip => '2000'
                          } ,
      :description => 'Ongoing Purchase',
      :starting_at => DateTime.now + 1.day,
      :ending_at => DateTime.new + 1.day + 1.year,
      :periodicity => :weekly
    }

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
  end
  
  def test_create_customer
    response = @gateway.create_customer(@customer_params)
    assert_false response.error?
    assert_not_nil response.customer_id
  end

  def test_invalid_create_customer
    params = @customer_params.dup
    params[:first_name] = ''
    response = @gateway.create_customer(params)

    assert response.error?
    assert_nil response.customer_id

    assert_not_nil response.error_details
    assert_not_nil response.error_severity
    assert_equal("The 'CustomerFirstName' element has an invalid value according to its data type.", response.error_details)
  end

  def test_query_customer
    response = @gateway.query_customer(95864)

    assert("customer reference", response.customer.ref)
    assert("mr", response.customer.title)
    assert("firstname", response.customer.first_name)
    assert("lastname", response.customer.last_name)
    assert("company", response.customer.company)
    assert("job description", response.customer.job_description)
    assert("email", response.customer.email)
    assert("address", response.customer.address)
    assert("suburb", response.customer.suburb)
    assert("canberra", response.customer.state)
    assert("9999", response.customer.post_code)
    assert("1111111111", response.customer.phone_1)
    assert("2222222222", response.customer.phone_2)
    assert("fax", response.customer.fax)
    assert("ACT", response.customer.state)
    assert("country", response.customer.country)
    assert("http://www.eway.com.au", response.customer.url)
    assert("comments", response.customer.comments)
  end

  def test_update_customer
    response =  @gateway.update_customer(95864, @customer_params)
    assert_false response.error?
  end

  def test_invalid_update_customer
    params = @customer_params.dup
    params[:first_name] = ''
    response = @gateway.update_customer(95864, params)
    assert response.error?

    assert_not_nil response.error_details
    assert_not_nil response.error_severity
    assert_equal("The 'CustomerFirstName' element has an invalid value according to its data type.", response.error_details)
  end

  def test_delete_customer
    response = @gateway.delete_customer(95864)
    assert_false response.error?
  end
end
