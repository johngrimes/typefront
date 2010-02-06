require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/strangers/features" do
  before do
    activate_authlogic
  end

  it 'should spit out valid XHTML' do
    render 'strangers/features', :layout => 'standard'
    response.should be_valid_xhtml
  end
end
