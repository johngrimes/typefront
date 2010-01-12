require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/passwords/edit" do
  fixtures :all
  before do
    activate_authlogic
    assigns[:user] = users(:bob)
  end

  it 'should spit out valid XHTML' do
    render 'passwords/edit', :layout => 'standard'
    response.should be_valid_xhtml
  end

  it 'should spit out valid XHTML when using a token' do
    assigns[:token] = users(:bob).perishable_token
    render 'passwords/edit', :layout => 'standard'
    response.should be_valid_xhtml
  end
end

