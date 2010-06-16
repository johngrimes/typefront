require 'spec_helper'

describe 'user_mailer/password_reset.erb' do
  before do
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'user_mailer/password_reset'
    response.should be_success
  end
end
