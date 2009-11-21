require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show" do
  fixtures :all
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
    render 'users/show', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
