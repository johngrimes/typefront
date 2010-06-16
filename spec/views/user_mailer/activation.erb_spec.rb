require 'spec_helper'

describe 'user_mailer/activation.erb' do
  before do
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'user_mailer/activation'
    response.should be_success
  end
end
