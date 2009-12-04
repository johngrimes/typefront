require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentNotificationsController do
  describe "POST 'create'" do
    it "should be successful" do
      PaymentNotification.any_instance.expects(:valid?).returns(true)
      post 'create',
        :custom => '12345678',
        :transaction_id => 'jkhdflwebw2394',
        :transaction_type => PaymentNotification::NEW_SUBSCRIPTION_STARTED,
        :status => 'somestatus'
      response.should be_success
    end
  end
end
