require 'spec_helper'

describe PasswordsController do
  before do
    login users(:bob)
  end

  describe 'new action' do
    it 'should be successful' do
      get 'new'
      assigns[:user].should_not be_nil
      response.should be_success
    end
  end

  describe 'create action' do
    it 'should be successful' do
      UserMailer.expects(:send_later)
      post 'create',
        :user => { :email => users(:bob).email }
      response.should be_success
    end

    it 'should render password reset request form if email can not be found' do
      UserMailer.expects(:deliver_password_reset).never
      post 'create',
        :user => { :email => 'bogus@email.com' }
      response.should render_template('passwords/new')
    end
  end

  describe 'edit action' do
    it 'should be successful' do
      get 'edit'
      response.should be_success
    end

    it 'should be successful with token' do
      logout
      get 'edit',
        :token => users(:bob).perishable_token
      response.should be_success
    end
  end

  describe 'update action' do
    it 'should be successful' do
      User.any_instance.expects(:update_attributes).returns(true)
      put 'update'
      flash[:notice].should_not be_nil
      response.should redirect_to(account_url)
    end

    it 'should render edit template if unsuccessful' do
      User.any_instance.expects(:update_attributes).returns(false)
      put 'update'
      response.should render_template('passwords/edit')
    end

    describe 'with token' do
      before do
        logout
      end

      it 'should be successful' do
        User.any_instance.expects(:update_attributes).returns(true)
        put 'update',
          :token => users(:bob).perishable_token
        flash[:notice].should_not be_nil
        response.should redirect_to(login_url)
      end

      it 'should render edit template if unsuccessful' do
        User.any_instance.expects(:update_attributes).returns(false)
        put 'update',
          :token => users(:bob).perishable_token
        response.should render_template('passwords/edit')
      end
    end
  end
end
