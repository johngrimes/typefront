require 'spec_helper'

describe 'admin_mailer/billing_job_missed_window.erb' do
  before do
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'admin_mailer/billing_job_missed_window'
    response.should be_success
  end
end
