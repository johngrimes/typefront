require 'spec_helper'

describe 'admin_mailer/new_user_joined.erb' do
  before do
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'admin_mailer/new_user_joined'
    response.should be_success
  end
end
