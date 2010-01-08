require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdminMailer do
  fixtures :all

  it "should deliver billing job error email" do
    doing {
      AdminMailer.deliver_billing_job_error users(:bob), 'Some error message'
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end
end
