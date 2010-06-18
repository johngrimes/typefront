require 'spec_helper'

describe 'users/show.html.haml' do
  before do
    login users(:bob)
    assigns[:user] = users(:bob)
  end

  it 'should render successfully if on a free plan' do
    render 'users/show', :layout => 'standard'
    response.should be_success
  end

  it 'should render successfully if on a paid plan' do
    User.any_instance.expects(:subscription_renewal).at_least_once.returns(2.weeks.from_now)
    render 'users/show', :layout => 'standard'
    response.should be_success
  end
end
