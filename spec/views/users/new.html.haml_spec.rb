require 'spec_helper'

describe 'users/new.html.haml' do
  before do
    activate_authlogic
  end

  it 'should render successfully if signing up for a free plan' do
    user = User.new
    user.subscription_level = User::FREE
    user.subscription_name = User::PLANS[User::FREE][:name]
    user.subscription_amount = User::PLANS[User::FREE][:amount]
    assigns[:user] = user
    render 'users/new', :layout => 'standard'
    response.should be_success
  end

  it 'should render successfully if signing up for a paid plan' do
    user = User.new
    user.subscription_level = User::POWER
    user.subscription_name = User::PLANS[User::POWER][:name]
    user.subscription_amount = User::PLANS[User::POWER][:amount]
    assigns[:user] = user
    render 'users/new', :layout => 'standard'
    response.should be_success
  end
end
