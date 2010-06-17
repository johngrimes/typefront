require 'spec_helper'

describe 'strangers/pricing.html.haml' do
  it 'should render successfully' do
    render 'strangers/pricing', :layout => 'blank'
    response.should be_success
  end

  describe 'when changing plans' do
    before do
      login users(:bob)
      assigns[:user] = users(:bob)
      assigns[:changing_plans] = true
    end

    it 'should render successfully when current plan is Free' do
      render 'strangers/pricing', :layout => 'blank'
      response.should be_success
    end

    it 'should render successfully when current plan is Plus' do
      assigns[:user].expects(:subscription_level).at_least_once.returns(User::PLUS)
      render 'strangers/pricing', :layout => 'blank'
      response.should be_success
    end

    it 'should render successfully when current plan is Power' do
      assigns[:user].expects(:subscription_level).at_least_once.returns(User::POWER)
      render 'strangers/pricing', :layout => 'blank'
      response.should be_success
    end
  end
end

