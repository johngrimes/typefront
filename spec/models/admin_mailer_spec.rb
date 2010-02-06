require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdminMailer do
  fixtures :all

  it "should deliver new user joined email" do
    doing {
      AdminMailer.deliver_new_user_joined users(:bob)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end

  it "should deliver payment received email" do
    doing {
      AdminMailer.deliver_payment_received invoices(:success)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end
  
  it "should deliver payment failed email" do
    doing {
      AdminMailer.deliver_payment_failed invoices(:failure)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end

  it "should deliver billing job error email" do
    doing {
      AdminMailer.deliver_billing_job_error users(:bob), 'Some error message'
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end

  it "should deliver billing job missed window email" do
    doing {
      AdminMailer.deliver_billing_job_missed_window users(:bob)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end
end
