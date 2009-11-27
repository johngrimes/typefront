require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DomainsController do
  fixtures :all

  before do
    login users(:bob)
  end

  describe 'Adding a new allowed domain through the API' do
    it 'should be successful' do
      Domain.any_instance.expects(:valid?).returns(true)
      post 'create',
        :format => 'json',
        :font_id => fonts(:duality).id
      assigns[:domain].should_not be_new_record
      flash[:notice].should_not be(nil)
      response.should be_success
      response.content_type.should =~ /application\/json/
    end

    it 'should return an error message if unsuccessful' do
      Domain.any_instance.expects(:valid?).returns(false)
      post 'create',
        :format => 'json',
        :font_id => fonts(:duality).id
      assigns[:domain].should be_new_record
      response.code.should == '422'
      response.content_type.should =~ /application\/json/
    end
  end

  describe "Removing an allowed domain" do
    it "should redirect to the parent font page" do
      Domain.any_instance.expects(:destroy).returns(domains(:fontlicious))
      delete 'destroy', :font_id => fonts(:duality), :id => domains(:fontlicious)
      response.should be_redirect
    end
  end

  describe "Removing an allowed domain through the API" do
    it "should be successful" do
      Domain.any_instance.expects(:destroy).returns(domains(:fontlicious))
      delete 'destroy', 
        :font_id => fonts(:duality), 
        :id => domains(:fontlicious),
        :format => 'json'
      response.should be_success
      response.content_type.should =~ /application\/json/
    end
  end
end
