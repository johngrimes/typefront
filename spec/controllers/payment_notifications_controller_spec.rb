require 'spec_helper'

describe PaymentNotificationsController do

  #Delete these examples and add some real ones
  it "should use PaymentNotificationsController" do
    controller.should be_an_instance_of(PaymentNotificationsController)
  end


  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end
end
