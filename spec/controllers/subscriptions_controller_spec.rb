require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubscriptionsController do
  include PaypalUrlHelper
  fixtures :all

  before do
    login users(:bob)
  end

  describe "GET 'index'" do
    it 'should be successful' do
      get 'index'
      assigns[:changing_plans].should be_true
      response.should be_success
      response.should render_template('strangers/pricing')
    end
  end

  describe "Getting the signup successful outcome page" do
    it "should be successful" do
      get 'outcome',
        :subscription_action => 'signup-successful'
      flash[:notice].should_not be_nil
      response.should redirect_to login_url
    end
  end

  describe "Getting the signup cancelled outcome page" do
    it "should be successful" do
      get 'outcome',
        :subscription_action => 'signup-cancelled'
      response.should be_success
      response.should render_template('subscriptions/outcomes/signup_cancelled')
    end
  end

  describe "Getting the change plans successful outcome page" do
    it "should be successful" do
      get 'outcome',
        :subscription_action => 'change-successful'
      response.should be_success
      response.should render_template('subscriptions/outcomes/change_successful')
    end
  end

  describe "Getting the change plans cancelled outcome page" do
    it "should be successful" do
      get 'outcome',
        :subscription_action => 'change-cancelled'
      response.should be_success
      response.should render_template('subscriptions/outcomes/change_cancelled')
    end
  end

  describe "Changing plans" do
    it 'should redirect to PayPal' do
      put 'update',
        :user => { :subscription_level => 1 }
      response.should redirect_to(paypal_modify_subscription_url(users(:bob), 1))
    end
  end

end
