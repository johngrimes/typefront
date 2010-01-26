require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/strangers/contact" do
  it 'should spit out valid XHTML' do
    render 'strangers/contact', :layout => 'blank'
    response.should be_valid_xhtml
  end
end
