require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/strangers/home" do
  it 'should spit out valid XHTML' do
    render 'strangers/home', :layout => 'blank'
    response.should be_valid_xhtml
  end
end

