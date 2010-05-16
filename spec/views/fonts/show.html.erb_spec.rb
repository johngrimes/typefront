require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/fonts/show" do
  fixtures :all

  before do
    login users(:bob)
    assigns[:font] = fonts(:duality)
    assigns[:formats] = fonts(:duality).formats
    assigns[:new_domain] = Domain.new
    render 'fonts/show', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
