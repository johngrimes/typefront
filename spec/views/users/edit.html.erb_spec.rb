require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/edit" do
  fixtures :all
  before do
    login users(:john)
    assigns[:user] = users(:john)
    render 'users/edit', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end

  it 'should spit out valid XHTML when upgrading or downgrading' do
    assigns[:subscription_level] == User::PLUS
    response.should be_valid_xhtml
  end
end
