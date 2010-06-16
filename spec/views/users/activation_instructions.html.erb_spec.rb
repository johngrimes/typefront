require 'spec_helper'

describe 'users/activation_instructions.html.erb' do
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
  end

  it 'should render successfully' do
    render 'users/activation_instructions', :layout => 'standard'
    response.should be_success
  end
end
