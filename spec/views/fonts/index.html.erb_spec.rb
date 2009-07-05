require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/home" do
  fixtures :all

  before do
    login users(:bob)
    assigns[:fonts] = users(:bob).fonts
    assigns[:font] = Font.new
    render 'fonts/index', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
