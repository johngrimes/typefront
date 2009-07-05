require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new" do
  before(:each) do
    activate_authlogic
    assigns[:user] = User.new
    render 'users/new', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
