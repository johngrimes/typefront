require 'spec_helper'

describe SubscriptionsController do
  before do
    login users(:bob)
  end

  describe 'edit action' do
    it 'should be successful' do
      get 'edit'
      assigns[:changing_plans].should be_true
      response.should be_success
      response.should render_template('strangers/pricing')
    end
  end

  describe 'update action' do
    it 'should be successful if coming from free plan' do
      put 'update',
        :user => { :subscription_level => User::PLUS.to_s }
      assigns[:subscription_level].should == User::PLUS
      assigns[:user].should == users(:bob)
      response.should be_success
      response.should render_template('users/edit')
    end

    it 'should be successful if coming from paying plan' do
      User.any_instance.expects(:update_attribute).with(:subscription_level, User::POWER)
      login users(:mary)
      put 'update',
        :user => { :subscription_level => User::POWER.to_s }
      assigns[:subscription_level].should == User::POWER
      response.should redirect_to(account_url(:just_upgraded => 'power'))
    end

    it 'should clear all billing if moving from paying plan to free plan' do
      User.any_instance.expects(:clear_all_billing).once
      login users(:john)
      put 'update',
        :user => { :subscription_level => User::FREE.to_s }
      assigns[:subscription_level].should == User::FREE
      response.should redirect_to(account_url)
    end
  end
end
