require 'spec_helper'

describe UserMailer do
  describe 'activation' do
    it 'should be successful' do
      UserMailer.deliver_activation users(:bob)
    end
  end

  describe 'receipt' do
    it 'should be successful' do
      UserMailer.deliver_receipt invoices(:success)
    end
  end

  describe 'password_reset' do
    it 'should be successful' do
      UserMailer.deliver_password_reset users(:john)
    end
  end
  
  describe 'payment_failed' do
    it 'should be successful' do
      UserMailer.deliver_payment_failed invoices(:failure)
    end
  end

  describe 'account_downgraded' do
    it 'should be successful' do
      UserMailer.deliver_account_downgraded invoices(:failure)
    end
  end
end
