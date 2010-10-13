require 'spec_helper'

describe ProcessBillingJob do
  it 'should perform job' do
    @user = mock()
    User.expects(:find).with(1).returns(@user)
    @user.expects(:process_billing)
    job = ProcessBillingJob.new(1)
    job.perform
  end

  it 'should send admin mail on error' do
    User.expects(:find).with(1).returns(nil)
    AdminMailer.expects(:deliver_billing_job_error)
    job = ProcessBillingJob.new(1)
    doing {
      job.perform
    }.should raise_error
  end
end
