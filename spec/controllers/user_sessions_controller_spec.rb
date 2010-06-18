require 'spec_helper'

describe UserSessionsController do
  describe 'new action' do
    it 'should be successful' do
      get 'new'
      assigns[:session].should be_a(UserSession)
      response.should be_success
    end
  end

  describe 'create action' do
    it 'should be successful' do
      UserSession.any_instance.expects(:save).returns(true)
      session[:return_to] = nil
      post 'create'
      flash[:notice].should_not be(nil)
      response.should redirect_to(fonts_url)
    end

    it 'should redirect to the previously requested page if successful' do
      UserSession.any_instance.expects(:save).returns(true)
      session[:return_to] = font_url(fonts(:duality))
      post 'create'
      flash[:notice].should_not be(nil)
      response.should redirect_to(font_url(fonts(:duality)))
    end

    it 'should render new template if unsuccessful' do
      UserSession.any_instance.expects(:save).returns(false)
      post 'create'
      response.should be_success
      response.should render_template('new')
    end
  end

  describe 'destroy action' do
    it 'should be successful' do
      login users(:bob)
      delete 'destroy'
      flash[:notice].should_not be(nil)
      response.should redirect_to(root_url)
    end

    it 'should act gracefully if already logged out' do
      logout
      delete 'destroy'
      flash[:notice].should_not be(nil)
      response.should redirect_to(root_url)
    end
  end
end
