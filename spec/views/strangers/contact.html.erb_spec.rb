require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/strangers/contact" do
  before do
    activate_authlogic
  end

  it 'should spit out valid XHTML' do
    render 'strangers/contact', :layout => 'standard'
    response.should be_valid_xhtml
  end
end
