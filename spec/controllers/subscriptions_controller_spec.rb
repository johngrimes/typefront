require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubscriptionsController do
  fixtures :all

  before do
    login users(:bob)
  end

  describe "GET 'edit'" do
    it 'should be successful' do
      get 'edit'
      assigns[:changing_plans].should be_true
      response.should be_success
      response.should render_template('strangers/pricing')
    end
  end

  describe 'Changing subscription level' do
    it 'should render billing details if coming from free plan' do
      put 'update',
        :user => { :subscription_level => User::PLUS }
      assigns[:subscription_level].should == User::PLUS
      assigns[:user].should == users(:bob)
      response.should be_success
      response.should render_template('users/edit')
    end

    it 'should be successful if billing details already filled out' do
      User.any_instance.expects(:update_attribute).with(:subscription_level, User::PLUS)
      login users(:john)
      put 'update',
        :user => { :subscription_level => User::PLUS }
      assigns[:subscription_level].should == User::PLUS
      response.should redirect_to(account_url)
    end

    it 'should clear all billing if moving from paying plan to free plan' do
      User.any_instance.expects(:clear_all_billing)
      login users(:john)
      put 'update',
        :user => { :subscription_level => User::FREE }
      assigns[:subscription_level].should == User::FREE
      response.should redirect_to(account_url)
    end
  end
end
