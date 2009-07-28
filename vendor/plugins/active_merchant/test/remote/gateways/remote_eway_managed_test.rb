require File.dirname(__FILE__) + '/../../test_helper'

class EwayManagedTest < Test::Unit::TestCase
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

    @event_params = {
      :customer_id => 95864,
      :inv_ref => 'INV_001',
      :inv_des => 'Invoice Description', 
      :cc_name => 'Bob Stewart',
      :cc_number => '4444333322221111',
      :cc_exp_month => 03,
      :cc_exp_year => 2022,
      :init_amt => 10000,
      :recur_amt => 20000,
      :init_date => DateTime.now + 1.day,
      :start_date => DateTime.now + 1.day + 1.month,
      :end_date => DateTime.now + 1.day + 1.month + 1.year,
      :interval => 1,
      :interval_type => :monthly
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

  def test_create_event
    response = @gateway.create_event(@event_params)
    assert_false response.error?
    assert_not_nil response.customer_id
    assert_not_nil response.rebill_id
  end

  def test_invalid_create_event
    params = @event_params.dup
    params[:cc_name] = ''
    response = @gateway.create_event(params)

    assert response.error?
    assert_nil response.rebill_id
    assert_not_nil response.customer_id

    assert_not_nil response.error_details
    assert_not_nil response.error_severity
    assert_equal("The 'RebillCCName' element has an invalid value according to its data type.", response.error_details)
  end

  def test_query_event
    response = @gateway.query_event(95864, 95864)
    assert_equal("95864", response.event.id)
    assert_equal("95864", response.event.customer_id)
    assert_equal("invoice reference 1", response.event.inv_ref)
    assert_equal("test event", response.event.inv_des)
    assert_equal("Test Test", response.event.cc_name)
    assert_equal("44443XXXXXXX1111", response.event.cc_number)
    assert_equal("12", response.event.cc_exp_month)
    assert_equal("12", response.event.cc_exp_year)
    assert_equal("500", response.event.init_amt)
    assert_equal("2008-10-06", response.event.init_date.strftime("%Y-%m-%d"))
    assert_equal("200", response.event.recur_amt)
    assert_equal("2008-10-21", response.event.start_date.strftime("%Y-%m-%d"))
    assert_equal("1", response.event.interval)
    assert_equal(:weekly, response.event.interval_type)
    assert_equal("2009-10-01", response.event.end_date.strftime("%Y-%m-%d"))
  end

  def test_update_event
    response =  @gateway.update_event(95864, @event_params)
    assert_false response.error?
  end

  def test_invalid_update_event
    params = @event_params.dup
    params[:cc_name] = ''
    response = @gateway.update_event(95864, params)
    assert response.error?

    assert_not_nil response.error_details
    assert_not_nil response.error_severity
    assert_equal("The 'RebillCCName' element has an invalid value according to its data type.", response.error_details)
  end

  def test_delete_event
    response = @gateway.delete_event(95864, 95864)
    assert_false response.error?
  end

  def test_recurring
    response = @gateway.recurring(1000, @credit_card_success, @recurring_params)
	puts response.inspect
    assert_false response.error?
    assert_not_nil response.customer_id
    assert_not_nil response.rebill_id
  end
end
