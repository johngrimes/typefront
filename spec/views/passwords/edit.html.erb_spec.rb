require 'spec_helper'

describe 'passwords/edit.html.erb' do
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'passwords/edit', :layout => 'standard'
    response.should be_success
  end

  it 'should render successfully when using a token' do
    assigns[:token] = users(:bob).perishable_token
    render 'passwords/edit', :layout => 'standard'
    response.should be_success
  end
end
