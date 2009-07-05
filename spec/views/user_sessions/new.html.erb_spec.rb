require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_sessions/new" do
  before(:each) do
    activate_authlogic
    assigns[:session] = UserSession.new
    render 'user_sessions/new', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
