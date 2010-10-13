require 'spec_helper'

describe FontsController do
  FIXTURE_FONT = "#{Rails.root}/spec/fixtures/duality.ttf"

  before do
    login users(:bob)
  end

  describe 'index action' do
    it 'should be successful' do
      get 'index'
      assigns[:fonts].should be_a(Array)
      response.should be_success
    end

    it 'should get a new font ready if allowed' do
      logout
      login users(:mary)
      get 'index'
      assigns[:fonts].should be_a(Array)
      assigns[:font].should be_a(Font)
      response.should be_success
    end

    it 'should redirect to login page if not logged in' do
      logout
      get 'index'
      session[:return_to].should_not be_nil
      flash[:notice].should_not be_nil
      response.should redirect_to(login_url)
    end

    it 'should should return a 401 if requesting JSON without authentication' do
      logout
      get 'index', :format => 'json'
      response.content_type.should =~ /application\/json/
      response.code.should == '401'
    end
  end

  describe 'index action (site fonts CSS)' do
    it 'should be successful' do
      get 'index', :format => 'css'
      assigns[:fonts].should be_a(Array)
      response.should be_success
      response.content_type.should =~ /text\/css/
    end
  end

  describe 'demo action' do
    it 'should be successful' do
      get 'demo', :id => fonts(:duality).id
      response.should be_success
    end
  end

  describe 'show action' do
    it 'should be successful' do
      get 'show',
        :id => fonts(:duality).id
      assigns[:font].should be_a(Font)
      assigns[:new_domain].should be_a(Domain)
      assigns[:active_tab].should == 'information'
      response.should be_success
    end

    it 'should be successful for a specified tab' do
      get 'show',
        :id => fonts(:duality).id,
        :tab_name => 'allowed-domains'
      assigns[:font].should be_a(Font)
      assigns[:new_domain].should be_a(Domain)
      assigns[:active_tab].should == 'allowed-domains'
      response.should be_success
    end

    it 'should deny anyone but the font owner' do
      logout
      login users(:john)
      get 'show',
        :id => fonts(:duality).id
      response.code.should == '403'
    end

    it 'should redirect to the processing page if there are pending generate jobs' do
      logout
      login users(:john)
      get 'show',
        :id => fonts(:still_processing).id
      response.should redirect_to(processing_font_url(fonts(:still_processing)))
    end

    it 'should only allow the font owner to see the processing page' do
      get 'show',
        :id => fonts(:still_processing).id
      response.code.should == '403'
    end
  end
  
  describe 'show action (font file download)' do
    describe 'valid requests' do
      before do
        Paperclip::Attachment.any_instance.expects(:path).once.returns(FIXTURE_FONT)
      end

      it 'should be successful if authorised via Origin header' do
        request.env['Origin'] = fonts(:duality).domains.first.domain
        get 'show',
          :id => fonts(:duality).id,
          :format => 'ttf'
        response.should be_success
        response.content_type.should == 'font/ttf'
        response.headers['Access-Control-Allow-Origin'].should == fonts(:duality).domains.first.domain
      end

      it 'should be successful if authorised via Referer header' do
        request.env['Referer'] = fonts(:duality).domains.first.domain + '/stuff/1.html'
        get 'show',
          :id => fonts(:duality).id,
          :format => 'ttf'
        response.should be_success
        response.content_type.should == 'font/ttf'
      end

      it 'should be successful if font has a wildcard domain' do
        request.env['Referer'] = 'http://www.somedomain.com/stuff/1.html'
        get 'show',
          :id => fonts(:triality).id,
          :format => 'ttf'
        response.should be_success
        response.content_type.should == 'font/ttf'
        response.headers['Access-Control-Allow-Origin'].should == '*'
      end

      it 'should be successful if the format is inactive but the request is from TypeFront' do
        request.env['Referer'] = $HOST_SSL + '/some_page'
        get 'show',
          :id => fonts(:triality).id,
          :format => 'otf'
        response.should be_success
        response.content_type.should == 'font/otf'
      end

      {'otf' => 'font/otf', 
       'woff' => 'font/woff', 
       'eot' => 'font/eot', 
       'svg' => 'image/svg+xml'}.each do |format, mime_type|
        it "should be successful for #{format.upcase} file" do
          request.env['Origin'] = fonts(:duality).domains.first.domain
          get 'show',
            :id => fonts(:duality).id,
            :format => format
          response.should be_success
          response.content_type.should == mime_type
        end
      end
    end

    it 'should not be successful if the format is inactive' do
      request.env['Referer'] = 'http://www.somedomain.com/stuff/1.html'
      get 'show',
        :id => fonts(:triality).id,
        :format => 'otf'
      response.code.should == '403'
    end

    it 'should return a 403 if not authorised' do
      logout
      request.env['Referer'] = 'http://someotherdomain.com/bogus.html'
      get 'show',
        :id => fonts(:duality).id,
        :format => 'otf'
      response.content_type.should =~ /application\/json/
      response.code.should == '403'
    end
  end

  describe 'show action (font include CSS)' do
    it 'should be successful' do
      get 'show', 
        :id => fonts(:duality).id,
        :format => 'css'
      assigns[:font].should be_a(Font)
      response.should be_success
      response.content_type.should =~ /text\/css/
    end
  end

  describe 'create action' do
    it 'should be successful' do
      Font.any_instance.expects(:valid?).returns(true)
      Font.any_instance.expects(:generate_all_formats)
      post 'create'
      assigns[:font].should_not be_new_record
      response.should be_redirect
    end

    it 'should render user home action if unsuccessful' do
      Font.any_instance.expects(:valid?).returns(false)
      post 'create'
      assigns[:font].should be_new_record
      response.code.should == '422'
      response.should render_template('fonts/index')
    end
  end

  describe 'update action' do
    it 'should be successful' do
      Font.any_instance.expects(:valid?).returns(true)
      FontFormat.expects(:new).never
      put 'update', 
        :id => fonts(:duality).id,
        :new_domains => "http://somedomain.com\nhttp://someotherdomain.com\nhttp://yetanotherdomain.com"
      assigns[:font].domains.count.should == 4
      flash[:notice].should_not be(nil)
      response.should be_redirect
    end

    it 'should render show font action if unsuccessful' do
      Font.any_instance.expects(:valid?).returns(false)
      put 'update', 
        :id => fonts(:duality).id
      response.code.should == '422'
      response.should render_template('fonts/show')
    end
  end

  describe 'destroy action' do
    it 'should be successful' do
      Font.any_instance.expects(:destroy).returns(fonts(:duality))
      delete 'destroy', :id => fonts(:duality).id
      response.should redirect_to(fonts_url)
    end
  end


  describe 'AJAX' do
    describe 'show action' do
      it 'should be successful for a specified tab' do
        get 'show',
          :id => fonts(:duality).id,
          :tab_name => 'allowed-domains',
          :format => 'js'
        assigns[:font].should be_a(Font)
        assigns[:new_domain].should be_a(Domain)
        assigns[:active_tab].should == 'allowed-domains'
        response.should be_success
        response.content_type.should =~ /text\/javascript/
      end
    end

    describe 'update action' do
      it 'should be successful' do
        Font.any_instance.expects(:valid?).returns(true)
        FontFormat.expects(:new).never
        put 'update', 
          :id => fonts(:duality).id,
          :new_domains => "http://somedomain.com\nhttp://someotherdomain.com\nhttp://yetanotherdomain.com",
          :format => 'js'
        assigns[:font].domains.count.should == 4
        response.should be_success
        response.content_type.should =~ /text\/javascript/
      end

      it 'should render show font action if unsuccessful' do
        Font.any_instance.expects(:valid?).returns(false)
        put 'update', 
          :id => fonts(:duality).id,
          :format => 'js'
        response.should be_success
        response.content_type.should =~ /text\/javascript/
      end
    end
  end

  describe 'API' do
    describe 'index action' do
      it 'should be successful' do
        get 'index', :format => 'json'
        assigns[:fonts].should be_a(Array)
        response.should be_success
        response.content_type.should =~ /application\/json/
      end
    end

    describe 'show action' do
      it 'should be successful' do
        get 'show',
          :id => fonts(:duality).id,
          :format => 'json'
        assigns[:font].should be_a(Font)
        response.should be_success
        response.content_type.should =~ /application\/json/
      end
    end

    describe 'create action' do
      it 'should be successful' do
        Font.any_instance.expects(:valid?).returns(true)
        Font.any_instance.expects(:generate_all_formats)
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
        response.code.should == '422'
        response.content_type.should =~ /application\/json/
      end
    end

    describe 'destroy action' do
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
end
