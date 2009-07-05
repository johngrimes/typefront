require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DomainsController do
  fixtures :all

  before do
    login users(:bob)
  end

  describe "Removing an allowed domain" do
    it "should redirect to the parent font page" do
      Domain.any_instance.expects(:destroy).returns(domains(:fontlicious))
      delete 'destroy', :font_id => fonts(:duality), :id => domains(:fontlicious)
      response.should be_redirect
    end
  end
end
