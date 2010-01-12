require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/passwords/create" do
  fixtures :all
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
    render 'passwords/create', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end

