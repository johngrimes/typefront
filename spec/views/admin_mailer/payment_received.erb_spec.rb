require 'spec_helper'

describe 'admin_mailer/payment_received.erb' do
  before do
    assigns[:invoice] = invoices(:success)
    assigns[:user] = users(:john)
  end

  it 'should render successfully' do
    render 'admin_mailer/payment_received'
    response.should be_success
  end
end
