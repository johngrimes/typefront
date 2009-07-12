require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StrangersController do
  integrate_views
  fixtures :all

  describe "GET 'home'" do
    it 'should be successful when not logged in' do
      logout
      get 'home'
      response.should be_success
    end

    it 'should be successful when logged in' do
      login users(:bob)
      get 'home'
      assigns[:fonts].should be_a(Array)
      assigns[:font].should be_a(Font)
      response.should be_success
    end
  end
end
