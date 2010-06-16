require 'spec_helper'

describe 'passwords/create.html.erb' do
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'passwords/create', :layout => 'standard'
    response.should be_success
  end
end

