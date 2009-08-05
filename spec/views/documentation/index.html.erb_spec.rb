require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/documentation/index" do
  before do
    activate_authlogic
    render 'documentation/index', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
