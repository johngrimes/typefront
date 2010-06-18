require 'spec_helper'

describe UsersController do
  before do
    login users(:bob)
  end

  describe 'new action' do
    it 'should be successful' do
      get 'new',
        :subscription_level => User::POWER
      assigns[:user].should be_a(User)
      response.should be_success
    end

    it 'should respond with not found if requested with an invalid subscription level' do
      doing {
        get 'new',
          :subscription_level => 4
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'create action' do
    it 'should be successful for free account' do
      User.any_instance.expects(:valid?).returns(true)
      User.any_instance.expects(:on_free_plan?).at_least_once.returns(true)
      User.any_instance.expects(:create_gateway_customer).never
      User.any_instance.expects(:process_billing).never
      post 'create'
      assigns[:user].should_not be_new_record
      response.should render_template('users/activation_instructions')
    end

    it 'should be successful for paying account' do
      User.any_instance.expects(:valid?).returns(true)
      User.any_instance.expects(:on_free_plan?).at_least_once.returns(false)
      User.any_instance.expects(:create_gateway_customer).returns(true)
      User.any_instance.expects(:process_billing).returns(true)
      post 'create',
        :user => { :card_number => Factory.build(:user).card_number }
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

  describe 'activate action' do
    it 'should be successful' do
      User.any_instance.expects(:update_attribute)
      get 'activate',
        :code => users(:bob).perishable_token
      response.should redirect_to(fonts_url)
    end

    it 'should be unsuccessful given a unknown activation code' do
      User.any_instance.expects(:update_attribute).never
      get 'activate',
        :code => 'adfkjg354123kjbda'
      response.should redirect_to(login_url)
    end
  end

  describe 'show action' do
    it 'should be successful' do
      get 'show'
      assigns[:user].should be_a(User)
      response.should be_success
    end
  end

  describe 'edit action' do
    it 'should be successful' do
      get 'edit'
      assigns[:user] == users(:bob)
      response.should be_success
    end
  end

  describe 'update action' do
    it 'should be successful' do
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

  describe 'destroy action' do
    it 'should be successful' do
      User.any_instance.expects(:destroy)
      delete 'destroy',
        :id => users(:bob).id
      response.should redirect_to(root_url)
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
