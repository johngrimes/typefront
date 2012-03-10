require 'spec_helper'

describe 'user_mailer/payment_failed.erb' do
  before do
    assigns[:invoice] = invoices(:failure)
    assigns[:user] = invoices(:failure).user
  end

  it 'should render successfully with 1 failure' do
    assigns[:fail_count] = 1
    render 'user_mailer/payment_failed'
    response.should be_success
  end

  it 'should render successfully with 2 failures' do
    assigns[:fail_count] = 2
    render 'user_mailer/payment_failed'
    response.should be_success
  end
end
