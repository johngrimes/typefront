require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserMailer do
  fixtures :all

  it "should deliver activation email" do
    doing {
      UserMailer.deliver_activation users(:bob)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end

  it "should deliver receipt email" do
    doing {
      UserMailer.deliver_receipt invoices(:success)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end

  it "should deliver password reset email" do
    doing {
      UserMailer.deliver_password_reset users(:john)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end
end
