require 'spec_helper'

describe StatsController do
  describe 'index action' do
    before do
      fake_result = [{
        'date' => '2010-01-01',
        'users' => '50',
        'requests' => '20000',
        'response_times' => '4.567'
      }]
      User.connection.expects(:select_all).at_least_once.returns(fake_result)
    end

    it 'should be successful' do
      get :index
      response.should be_success
      assigns[:total_users_url].should be_a(String)
      assigns[:plan_breakdown_url].should be_a(String)
      assigns[:requests_url].should be_a(String)
      assigns[:response_times_url].should be_a(String)
      assigns[:formats_breakdown_url].should be_a(String)
    end
  end
end
