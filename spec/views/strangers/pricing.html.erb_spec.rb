require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/strangers/pricing" do
  fixtures :all

  it 'should spit out valid XHTML' do
    render 'strangers/pricing', :layout => 'blank'
    response.should be_valid_xhtml
  end

  it 'should spit out valid XHTML when changing plans' do
    login users(:bob)
    assigns[:user] = users(:bob)
    assigns[:changing_plans] = true
    render 'strangers/pricing', :layout => 'blank'
    response.should be_valid_xhtml
  end
end

