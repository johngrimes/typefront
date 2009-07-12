require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FontsController do
  integrate_views
  fixtures :all

  before do
    login users(:bob)
  end

  describe "Getting a listing of your fonts" do
    it 'should be successful in HTML format' do
      get 'index'
      assigns[:fonts].should be_a(Array)
      assigns[:font].should be_a(Font)
      response.should be_success
    end

    it 'should be successful in CSS format' do
      get 'index', :format => 'css'
      assigns[:fonts].should be_a(Array)
      response.should be_success
      response.content_type.should =~ /text\/css/
    end

    it 'should be successful in JSON format' do
      get 'index', :format => 'json'
      assigns[:fonts].should be_a(Array)
      response.should be_success
      response.content_type.should =~ /application\/json/
    end

    it 'should redirect to login page if not logged in' do
      logout
      get 'index'
      session[:return_to].should_not be_nil
      flash[:notice].should_not be_nil
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "Getting details for a font" do
    it 'should be successful in HTML format' do
      get 'show',
        :id => fonts(:duality).id
      assigns[:font].should be_a(Font)
      assigns[:new_domain].should be_a(Domain)
      response.should be_success
    end

    it 'should be successful in JSON format' do
      get 'show',
        :id => fonts(:duality).id,
        :format => 'json'
      assigns[:font].should be_a(Font)
      response.should be_success
      response.content_type.should =~ /application\/json/
    end
  end
  
  describe 'Downloading a font file' do
    it 'should be successful if authorised' do
      doing {
        request.env['Origin'] = fonts(:duality).domains.first.domain
        get 'show',
          :id => fonts(:duality).id,
          :format => 'font'
        response.should be_success
        response.content_type.should == 'application/x-font-ttf'
      }.should raise_error(ActionController::MissingFile)
    end

    it 'should raise an error if not authorised' do
      doing {
        logout
        request.env['Origin'] = 'someotherdomain.com'
        get 'show',
          :id => fonts(:duality).id,
          :format => 'font'
        response.should be_success
        response.content_type.should == 'application/x-font-ttf'
      }.should raise_error(PermissionDenied)
    end
  end

  describe 'Adding a new font' do
    it 'should redirect if successful' do
      Font.any_instance.expects(:valid?).returns(true)
      post 'create'
      assigns[:font].should_not be_new_record
      flash[:notice].should_not be(nil)
      response.should be_redirect
    end

    it 'should render user home action if unsuccessful' do
      Font.any_instance.expects(:valid?).returns(false)
      post 'create'
      assigns[:font].should be_new_record
      response.should be_success
      response.should render_template('fonts/index')
    end
  end

  describe 'Adding a new font through the API' do
    it 'should be successful' do
      Font.any_instance.expects(:valid?).returns(true)
      post 'create',
        :format => 'json'
      assigns[:font].should_not be_new_record
      response.should be_success
      response.content_type.should =~ /application\/json/
    end

    it 'should return an error message if unsuccessful' do
      Font.any_instance.expects(:valid?).returns(false)
      post 'create',
        :format => 'json'
      assigns[:font].should be_new_record
      response.should be_success
      response.content_type.should =~ /application\/json/
    end
  end

  describe 'Updating a font' do
    it 'should redirect if successful' do
      Font.any_instance.expects(:valid?).returns(true)
      put 'update', 
        :id => fonts(:duality).id,
        :new_domains => "somedomain.com\nsomeotherdomain.com\nyetanotherdomain.com"
      flash[:notice].should_not be(nil)
      response.should be_redirect
    end

    it 'should render show font action if unsuccessful' do
      Font.any_instance.expects(:valid?).returns(false)
      put 'update', 
        :id => fonts(:duality).id
      response.should be_success
      response.should render_template('fonts/show')
    end
  end

  describe 'Updating a font through the API' do
    it 'should be successful' do
      Font.any_instance.expects(:valid?).returns(true)
      put 'update', 
        :id => fonts(:duality).id,
        :new_domains => "somedomain.com\nsomeotherdomain.com\nyetanotherdomain.com",
        :format => 'json'
      response.should be_success
      response.content_type.should =~ /application\/json/
    end

    it 'should return an error message if unsuccessful' do
      Font.any_instance.expects(:valid?).returns(false)
      put 'update', 
        :id => fonts(:duality).id,
        :format => 'json'
      response.should be_success
      response.content_type.should =~ /application\/json/
    end
  end

  describe 'Removing a font' do
    it 'should redirect to user home' do
      Font.any_instance.expects(:destroy).returns(fonts(:duality))
      delete 'destroy', :id => fonts(:duality).id
      response.should redirect_to(home_url)
    end
  end

  describe 'Removing a font through the API' do
    it 'should be successful' do
      Font.any_instance.expects(:destroy).returns(fonts(:duality))
      delete 'destroy', 
        :id => fonts(:duality).id,
        :format => 'json'
      response.should be_success
      response.content_type.should =~ /application\/json/
    end
  end
end
