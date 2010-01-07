require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'delayed_job'

describe User do
  fixtures :all

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
      :card_expiry => Time.now
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

  it 'should successfully create a gateway customer' do
    users(:john).card_number = '4564621016895669'
    users(:john).card_cvv = '214'
    users(:john).create_gateway_customer
  end

  it 'should successfully process billing' do
    Delayed::Job.expects(:enqueue).once
    users(:john).process_billing
  end
end
