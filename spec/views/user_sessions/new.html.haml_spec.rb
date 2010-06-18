require 'spec_helper'

describe 'user_sessions/new.html.haml' do
  before do
    activate_authlogic
    assigns[:session] = UserSession.new
  end

  it 'should render successfully' do
    render 'user_sessions/new', :layout => 'standard'
    response.should be_success
  end
end
