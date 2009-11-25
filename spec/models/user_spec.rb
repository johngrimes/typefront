require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
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
      :country => 'Australia'
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
end
