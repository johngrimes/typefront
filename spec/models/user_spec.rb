require 'spec_helper'

describe User do
  fixtures :all

  describe 'validation' do
    before do
      @valid = Factory.build(:user)
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

  describe 'create_gateway_customer' do
    it 'should be successful' do
      @response = 12345
      @user = users(:john)
      BigCharger.any_instance.expects(:create_customer).with(
        'CustomerRef' => @user.id,
        'FirstName' => @user.first_name,
        'LastName' => @user.last_name,
        'Email' => @user.email,
        'Address' => '38/8 Briggs Road',
        'Suburb' => @user.city,
        'State' => @user.state,
        'Country' => 'au',
        'PostCode' => @user.postcode,
        'Company' => @user.company_name,
        'CCNameOnCard' => @user.card_name,
        'CCNumber' => '4564621016895669',
        'CCExpiryMonth' => @user.card_expiry.month,
        'CCExpiryYear' => @user.card_expiry.year.to_s[2..3],
        'Title' => 'Mr.',
        'Fax' => '',
        'Phone' => '',
        'Mobile' => '',
        'JobDesc' => '',
        'Comments' => '',
        'URL' => ''
      ).returns(@response)
      User.any_instance.expects(:update_attribute)
      users(:john).card_number = '4564621016895669'
      users(:john).card_cvv = '214'
      users(:john).create_gateway_customer
    end
  end

 describe 'update_gateway_customer' do
    it 'should be successful' do
      BigCharger.any_instance.expects(:update_customer).returns(true)
      users(:john).card_number = '4564621016895669'
      users(:john).card_cvv = '214'
      users(:john).update_gateway_customer
    end
  end

  describe 'billing' do
    before(:each) do
      @response = {
        'ewayAuthCode' => 'HDN758943',
        'ewayTrxnNumber' => '12345',
        'ewayTrxnStatus' => 'True',
        'ewayTrxnError' => 'Some error',
        'ewayReturnAmount' => (users(:john).subscription_amount * 100).to_s
      }
    end

    it 'should enqueue the first job if subscription renewal is blank' do
      Resque.expects(:enqueue_at).once
      BigCharger.any_instance.expects(:process_payment).never
      users(:john).process_billing
    end

    it 'should bill for one period straight away if subscription renewal is blank and skip trial period is set' do
      Resque.expects(:enqueue_at).once
      users(:john).expects(:bill_for_one_period).once.returns(true)
      users(:john).process_billing(:skip_trial_period => true)
    end

    it 'should successfully process billing if within the automatic billing window' do
      Resque.expects(:enqueue_at).once
      users(:john).expects(:bill_for_one_period).once.returns(true)
      users(:john).subscription_renewal = Time.now - (User::AUTOMATIC_BILLING_WINDOW - 3.seconds)
      users(:john).process_billing
    end

    it 'should send an email to the admin if attempting to bill after the automatic billing window' do
      BigCharger.any_instance.expects(:process_payment).never
      users(:john).subscription_renewal = Time.now - (User::AUTOMATIC_BILLING_WINDOW + 3.seconds)
      doing {
        users(:john).process_billing
      }.should change(ActionMailer::Base.deliveries, :size).by(+1)
    end

    it 'should successfully bill one period' do
      @user = users(:john)
      @invoice = invoices(:success)
      @from_date = Time.now
      @to_date = Time.now + User::BILLING_PERIOD
      Invoice.expects(:new).with(
        :user_id => @user.id,
        :amount => @user.subscription_amount,
        :description => "Payment for TypeFront #{@user.subscription_name} subscription from #{@from_date} to #{@to_date}"
      ).returns(@invoice)
      @invoice.expects(:save!).times(2)
      BigCharger.any_instance.expects(:process_payment).with(
        @user.gateway_customer_id,
        @user.subscription_amount * 100,
        @invoice.id,
        @invoice.description
      ).returns(@response)
      UserMailer.expects(:deliver_receipt).once
      AdminMailer.expects(:deliver_payment_received).once
      @user.bill_for_one_period(@from_date, @to_date).should be_true
    end

    it 'should successfully bill with a custom amount' do
      @response['ewayReturnAmount'] = '5000'
      BigCharger.any_instance.expects(:process_payment).returns(@response)
      UserMailer.expects(:deliver_receipt).once
      AdminMailer.expects(:deliver_payment_received).once
      doing {
        users(:john).bill_for_one_period(Time.now, Time.now + 6.months, 50).should be_true
      }.should change(Invoice, :count).by(+1)
    end

    it 'should raise exception if return amount is different to billing amount' do
      @right_amount = users(:john).subscription_amount * 100
      @wrong_amount = (users(:john).subscription_amount * 100) - 5
      @response['ewayReturnAmount'] = @wrong_amount.to_s
      BigCharger.any_instance.expects(:process_payment).returns(@response)
      doing {
        users(:john).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD).should_not be_true
      }.should raise_error(Exception, "Received payment response from gateway with different amount (#{@wrong_amount}) to invoice amount (#{@right_amount}).")
    end

    it 'should still add info to invoice on failed billing' do
      @response['ewayTrxnStatus'] = 'False'
      BigCharger.any_instance.expects(:process_payment).returns(@response)
      Invoice.any_instance.expects(:save!).times(2)
      AdminMailer.expects(:deliver_payment_failed).once
      UserMailer.expects(:deliver_payment_failed).once
      Resque.expects(:enqueue_at).once
      users(:pilferer).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD).should_not be_true
    end

    it 'should still add info to invoice when exception related to expired credit card is raised' do
      BigCharger.any_instance.expects(:process_payment).raises(
        BigCharger::Error,
        'eWAY server responded with "Credit Card has expired. Please update ' +
        'credit card details and try again." (soap:Client)'
      )
      Invoice.any_instance.expects(:save!).times(2)
      AdminMailer.expects(:deliver_payment_failed).once
      UserMailer.expects(:deliver_payment_failed).once
      Resque.expects(:enqueue_at).once
      users(:pilferer).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD).should_not be_true
    end

    it 'should downgrade the account on the third failed billing' do
      @response['ewayTrxnStatus'] = 'False'
      BigCharger.any_instance.expects(:process_payment).returns(@response)
      Invoice.any_instance.expects(:save!).times(2)
      AdminMailer.expects(:deliver_payment_failed).once
      UserMailer.expects(:deliver_account_downgraded).once
      users(:cheater).bill_for_one_period(Time.now, Time.now + User::BILLING_PERIOD).should_not be_true
      users(:cheater).payment_fail_count.should == 0
      users(:cheater).subscription_level.should == 0
    end

    it 'should successfully clear all billing' do
      Resque.expects(:remove_delayed).once
      users(:john).clear_all_billing
    end

    it 'should successfully reset subscription renewal date' do
      Resque.expects(:enqueue_at).once
      users(:john).reset_subscription_renewal(Time.now + User::BILLING_PERIOD)
    end
  end

  describe 'clip_fonts_to_plan_limit' do
    it 'should be successful' do
      Font.any_instance.expects(:destroy)
      users(:bob).clip_fonts_to_plan_limit
    end
  end

  describe 'full_name' do
    it 'should be successful' do
      users(:john).full_name.should == 'John Grimes'
    end
  end
end
