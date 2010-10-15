require 'spec_helper'

describe BillingJob do
  it 'should perform job' do
    @user = mock()
    User.expects(:find).with(1).returns(@user)
    @user.expects(:process_billing)
    BillingJob.perform(:user_id => 1)
  end

  it 'should email admin on failure' do
    @user = mock()
    User.expects(:find).with(1).returns(@user)
    AdminMailer.expects(:deliver_billing_job_error).with(@user, 'Some error')
    BillingJob.on_failure_email_admin(Exception.new('Some error'), :user_id => 1)
  end
end
