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
    it 'should redirect to home if successful' do
      User.any_instance.expects(:valid?).returns(true)
      post 'create',
        :accept_terms => true
      assigns[:user].should_not be_new_record
      flash[:notice].should_not be(nil)
      response.should redirect_to(home_path)
    end

    it 'should render new template if unsuccessful' do
      User.any_instance.expects(:valid?).returns(false)
      post 'create',
        :accept_terms => true
      assigns[:user].should be_new_record
      response.should be_success
      response.should render_template('new')
    end

    it 'should render new template if terms not accepted' do
      post 'create',
        :accept_terms => false
      assigns[:user].should be_new_record
      response.should be_success
      response.should render_template('new')
    end
  end
end
