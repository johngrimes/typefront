require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Invoice do
  fixtures :all

  before(:each) do
    @valid_attributes = {
      :user_id => users(:john).id,
      :amount => 9.99,
      :description => "value for description",
      :paid_at => Time.now,
      :auth_code => "value for auth_code",
      :gateway_txn_id => "value for gateway_txn_id",
      :error_message => "value for error_message"
    }
  end

  it "should create a new instance given valid attributes" do
    Invoice.create!(@valid_attributes)
  end
end
