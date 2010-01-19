require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'delayed_job'

describe User do
  fixtures :all

  describe 'attributes' do
    before(:each) do
      @valid_attributes = {
        :email => 'test@test.com',
        :password => 'password',
        :password_confirmation => 'password',
        :first_name => 'Barry',
        :last_name => 'Bloggs',
        :address_1 => '50 Abalone Avenue',
        :city => 'Gold Coast',
        :state => 'Queensland',
        :postcode => '4216',
        :country => 'Australia',
        :card_type => 'visa',
        :card_name => 'Mr Barry B Bloggs',
        :card_number => '4564621016895669',
        :card_cvv => '376',
        :card_expiry => Time.now,
        :terms => '1'
      }
      @valid = User.new(@valid_attributes)
    end

    it 'should be valid given valid attributes' do
      @valid.should be_valid
    end

    it 'should be invalid without an email address' do
      @invalid = @valid
      @invalid.email = nil
      @invalid.should_not be_valid
    end

    it 'should be invalid with a badly formatted email address' do
      @invalid = @valid
      @invalid.email = 'fred'
      @invalid.should_not be_valid
    end

    it 'should not save if the password confirmation is different' do
      @invalid = @valid
      @invalid.password_confirmation = 'something different'
      doing { @invalid.save! }.should raise_error ActiveRecord::RecordInvalid
    end

    it 'should be valid without a credit card number if card validation is off' do
      @valid.card_validation_on = false
      @valid.card_number = nil
      @valid.should be_valid
    end
  end

  describe 'gateway customer' do
    it 'should create successfully' do
      @response = stub(:id => 12345)
      @response.expects(:id=)
      ::GATEWAY.expects(:create_customer).returns(@response)
      User.any_instance.expects(:update_attributes!)
      users(:john).card_number = '4564621016895669'
      users(:john).card_cvv = '214'
      users(:john).create_gateway_customer
    end
    
    it 'should update successfully' do
      ::GATEWAY.expects(:update_customer).returns(true)
      users(:john).card_number = '4564621016895669'
      users(:john).card_cvv = '214'
      users(:john).update_gateway_customer
    end
  end

  describe 'billing' do
    before(:each) do
      @response = stub(:auth_code => 'HDN758943',
        :transaction_number => 12345,
        :error => 'Some error')
    end

    it 'should enqueue the first job if subscription renewal is blank' do
      Delayed::Job.expects(:enqueue).once
      ::GATEWAY.expects(:process_payment).never
      users(:john).process_billing
    end
    
    it 'should bill for one period straight away if subscription renewal is blank and skip trial period is set' do
      Delayed::Job.expects(:enqueue).once
      users(:john).expects(:bill_for_one_period).once
      users(:john).process_billing(:skip_trial_period => true)
    end

    it 'should successfully process billing if within the automatic billing window' do
      Delayed::Job.expects(:enqueue).once
      users(:john).expects(:bill_for_one_period).once
      users(:john).subscription_renewal = Time.now - (User::AUTOMATIC_BILLING_WINDOW - 3.seconds)
      users(:john).process_billing
    end

    it 'should send an email to the admin if attempting to bill after the automatic billing window' do
      ::GATEWAY.expects(:process_payment).never
      users(:john).subscription_renewal = Time.now - (User::AUTOMATIC_BILLING_WINDOW + 3.seconds)
      doing {
        users(:john).process_billing
      }.should change(ActionMailer::Base.deliveries, :size).by(+1)
    end

    it 'should successfully bill one period' do
      ::GATEWAY.expects(:process_payment).returns(@response)
      @response.expects(:status).returns(true)
      @response.expects(:return_amount).returns(users(:john).subscription_amount * 100)
      UserMailer.expects(:deliver_receipt).once
      doing {
        users(:john).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD)
      }.should change(Invoice, :count).by(+1)
    end

    it 'should raise exception if return amount is different to billing amount' do
      ::GATEWAY.expects(:process_payment).returns(@response)
      @response.expects(:status).returns(true)
      @response.expects(:return_amount).returns((users(:john).subscription_amount * 100) - 5)
      doing {
        users(:john).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD)
      }.should raise_error(Exception, 'Received payment response from gateway with different amount to invoice amount.')
    end

    it 'should still add info to invoice on failed billing' do
      ::GATEWAY.expects(:process_payment).returns(@response)
      @response.expects(:status).returns(false)
      Invoice.any_instance.expects(:update_attributes!).once
      users(:john).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD)
    end

    it 'should successfully clear all billing' do
      users(:john).expects(:on_free_plan?).returns(true)
      users(:john).clear_all_billing
    end

    it 'should successfully reset subscription renewal date' do
      Delayed::Job.expects(:enqueue).once
      users(:john).reset_subscription_renewal(Time.now + User::BILLING_PERIOD)
    end
  end
end
