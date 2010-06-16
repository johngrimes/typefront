require 'spec_helper'

describe 'user_mailer/receipt.erb' do
  before do
    assigns[:user] = users(:bob)
    assigns[:invoice] = invoices(:success)
  end

  it 'should render successfully' do
    render 'user_mailer/receipt'
    response.should be_success
  end
end
