require 'spec_helper'

describe 'admin_mailer/payment_failed.erb' do
  before do
    assigns[:invoice] = invoices(:failure)
    assigns[:user] = users(:john)
  end

  it 'should render successfully' do
    render 'admin_mailer/payment_failed'
    response.should be_success
  end
end
