require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubscriptionsController do
  fixtures :all

  before do
    login users(:bob)
  end

  describe "GET 'index'" do
    it 'should be successful' do
      get 'index'
      assigns[:changing_plans].should be_true
      response.should be_success
      response.should render_template('strangers/pricing')
    end
  end
end
