require 'spec_helper'

describe MailJob do
  it 'should perform job' do
    AdminMailer.expects(:deliver_new_user_joined).with(1)
    MailJob.perform(:admin, :new_user_joined, 1)
  end
end
