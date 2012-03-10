require 'spec_helper'

describe 'user_mailer/account_downgraded.erb' do
  before do
    assigns[:invoice] = invoices(:failure)
    assigns[:user] = invoices(:failure).user
  end

  it 'should render successfully' do
    render 'user_mailer/account_downgraded'
    response.should be_success
  end
end
