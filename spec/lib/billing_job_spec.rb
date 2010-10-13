require 'spec_helper'

describe BillingJob do
  it 'should perform job' do
    @user = mock()
    User.expects(:find).with(1).returns(@user)
    @user.expects(:process_billing)
    BillingJob.perform(:user_id => 1)
  end
end
