require 'spec_helper'

describe AdminMailer do
  describe 'new_user_joined' do
    it 'should be successful' do
      AdminMailer.deliver_new_user_joined users(:bob)
    end
  end

  describe 'payment_received' do
    it 'should be successful' do
      AdminMailer.deliver_payment_received invoices(:success)
    end
  end

  describe 'payment_failed' do
    it 'should be successful' do
      AdminMailer.deliver_payment_failed invoices(:failure)
    end
  end

  describe 'billing_job_error' do
    it 'should be successful' do
      AdminMailer.deliver_billing_job_error users(:bob), 'Some error message'
    end
  end

  describe 'billing_job_missed_window' do
    it 'should be successful' do
      AdminMailer.deliver_billing_job_missed_window users(:bob)
    end
  end
end
