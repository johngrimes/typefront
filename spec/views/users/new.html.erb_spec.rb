require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new" do
  before(:each) do
    activate_authlogic
    user = User.new
    user.subscription_level = User::POWER
    user.subscription_name = User::PLANS[User::POWER][:name]
    user.subscription_amount = User::PLANS[User::POWER][:amount]
    assigns[:user] = user
    render 'users/new', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
