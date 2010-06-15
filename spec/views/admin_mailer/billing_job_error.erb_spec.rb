require 'spec_helper'

describe 'admin_mailer/billing_job_error.erb' do
  before do
    assigns[:user] = users(:bob)
    assigns[:error_message] = 'Some error message.'
  end

  it 'should render successfully' do
    render 'admin_mailer/billing_job_error'
    response.should be_success
  end
end
