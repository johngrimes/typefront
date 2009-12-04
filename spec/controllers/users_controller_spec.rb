require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  fixtures :all

  before do
    login users(:bob)
  end

  describe "GET 'new'" do
    it 'should be successful' do
      get 'new',
        :subscription_level => User::POWER
      assigns[:user].should be_a(User)
      response.should be_success
    end
  end

  describe "Signing up" do
    it 'should redirect to activation instructions if for free account' do
      User.any_instance.expects(:valid?).returns(true)
      User.any_instance.expects(:on_free_plan?).returns(true)
      post 'create',
        :accept_terms => true
      assigns[:user].should_not be_new_record
      response.should render_template('users/activation_instructions')
    end

    it 'should redirect to PayPal if for paying account' do
      User.any_instance.expects(:valid?).returns(true)
      User.any_instance.expects(:on_free_plan?).returns(false)
      User.any_instance.expects(:subscription_name).returns('Power')
      post 'create',
        :accept_terms => true
      assigns[:user].should_not be_new_record
      response.should be_redirect
    end

    it 'should render new template if unsuccessful' do
      User.any_instance.expects(:valid?).returns(false)
      post 'create',
        :accept_terms => true
      assigns[:user].should be_new_record
      response.code.should == '422'
      response.should render_template('new')
    end

    it 'should render new template if terms not accepted' do
      post 'create',
        :accept_terms => false
      assigns[:user].should be_new_record
      response.code.should == '422'
      response.should render_template('new')
    end
  end

  describe "GET 'show'" do
    it 'should be successful' do
      get 'show'
      assigns[:user].should be_a(User)
      response.should be_success
    end
  end
  
  describe "GET 'select_plan'" do
    it 'should be successful' do
      get 'select_plan'
      assigns[:changing_plans].should be_true
      response.should be_success
      response.should render_template('strangers/pricing')
    end
  end

  describe "Changing plans" do
    it 'should redirect to home if successful' do
      User.any_instance.expects(:valid?).returns(true)
      put 'update',
        :id => users(:bob).id,
        :user => { :subscription_level => 1 }
      response.should be_redirect
      flash[:notice].should_not be(nil)
      response.should redirect_to(account_url)
    end

    it 'should render home template if unsuccessful' do
      User.any_instance.expects(:valid?).returns(false)
      put 'update',
        :id => users(:bob).id,
        :user => { :subscription_level => 1 }
      response.code.should == '422'
      response.should render_template('users/show')
    end
  end

  describe "Cancelling an account" do
    it 'should redirect to home if successful' do
      User.any_instance.expects(:destroy)
      delete 'destroy',
        :id => users(:bob).id
      response.should redirect_to(home_url)
    end

    it 'should not destroy the account unless the user is logged in' do
      login users(:john)
      User.any_instance.expects(:destroy).never
      delete 'destroy',
        :id => users(:bob).id
      response.should redirect_to(home_url)
    end
  end
end
