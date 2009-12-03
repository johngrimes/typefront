require 'spec_helper'

describe PaymentNotification do
  before(:each) do
    @valid_attributes = {
      :params => "value for params",
      :user_id => 1,
      :status => "value for status",
      :transaction_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    PaymentNotification.create!(@valid_attributes)
  end
end
