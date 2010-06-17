require 'spec_helper'

describe 'passwords/new.html.haml' do
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'passwords/new', :layout => 'standard'
    response.should be_success
  end
end

