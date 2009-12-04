require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentNotificationsController do
  describe "POST 'create'" do
    it "should be successful" do
      PaymentNotification.any_instance.expects(:valid?).returns(true)
      post 'create'
      response.should be_success
    end
  end
end
