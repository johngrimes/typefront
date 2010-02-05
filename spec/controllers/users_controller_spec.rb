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
      User.any_instance.expects(:on_free_plan?).at_least_once.returns(true)
      User.any_instance.expects(:create_gateway_customer).never
      User.any_instance.expects(:process_billing).never
      post 'create'
      assigns[:user].should_not be_new_record
      response.should render_template('users/activation_instructions')
    end

    it 'should redirect to home if for paying account' do
      User.any_instance.expects(:valid?).returns(true)
      User.any_instance.expects(:on_free_plan?).at_least_once.returns(false)
      User.any_instance.expects(:create_gateway_customer).returns(true)
      User.any_instance.expects(:process_billing).returns(true)
      post 'create'
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

  describe "Activating an account" do
    it 'should redirect to home if successful' do
      User.any_instance.expects(:update_attribute)
      get 'activate',
        :code => users(:bob).perishable_token
      response.should redirect_to(home_url)
    end

    it 'should be unsuccessful given a unknown activation code' do
      User.any_instance.expects(:update_attribute).never
      get 'activate',
        :code => 'adfkjg354123kjbda'
      response.should redirect_to(login_url)
    end
  end

  describe "Get account page" do
    it 'should be successful' do
      get 'show'
      assigns[:user].should be_a(User)
      response.should be_success
    end
  end

  describe "Get change billing details form" do
    it 'should be successful' do
      get 'edit'
      assigns[:user] == users(:bob)
      response.should be_success
    end
  end

  describe "Changing billing details" do
    it 'should redirect to the account page if successful' do
      login users(:john)
      User.any_instance.expects(:update_attributes).returns(true)
      User.any_instance.expects(:update_gateway_customer)
      put 'update',
        :id => users(:john).id,
        :user => { :subscription_level => User::PLUS }
      flash[:notice].should_not be_nil
      response.should redirect_to(account_url)
    end

    it 'should create a gateway customer and process billing if user was on a free account' do
      login users(:bob)
      User.any_instance.expects(:valid?).returns(true)
      User.any_instance.expects(:create_gateway_customer)
      User.any_instance.expects(:process_billing).with(:skip_trial_period => true)
      put 'update',
        :id => users(:bob).id,
        :user => { :subscription_level => User::PLUS }
      flash[:notice].should_not be_nil
      response.should redirect_to(account_url)
    end

    it 'should render edit billing details page if unsuccessful' do
      login users(:john)
      User.any_instance.expects(:update_attributes).returns(false)
      User.any_instance.expects(:update_gateway_customer).never
      User.any_instance.expects(:process_billing).never
      put 'update',
        :id => users(:john).id
      response.should render_template('users/edit')
    end

    it 'should not allow changes to internal user fields' do
      login users(:john)
      User.any_instance.expects(:update_gateway_customer).never
      put 'update',
        :id => users(:john).id,
        :user => { :fonts_allowed => 25000 }
      response.should_not be_success
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
      response.code.should == '403'
    end
  end
end
