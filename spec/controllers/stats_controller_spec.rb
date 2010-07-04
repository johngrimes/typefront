require 'spec_helper'

describe StatsController do
  describe 'index action' do
    before do
      fake_result = [{
        'date' => '2010-01-01',
        'users' => '50',
        'users_joined' => '50',
        'requests' => '20000',
        'response_times' => '4.567'
      }]
      User.connection.expects(:select_all).at_least_once.returns(fake_result)
    end

    it 'should be successful' do
      get :index
      response.should be_success
      assigns[:unactivated_users_total].should be_a(Array)
      assigns[:free_users_total].should be_a(Array)
      assigns[:paying_users_total].should be_a(Array)
      assigns[:free_users_joined].should be_a(Array)
      assigns[:plus_users_joined].should be_a(Array)
      assigns[:power_users_joined].should be_a(Array)
      assigns[:free_user_count].should be_a(Fixnum)
      assigns[:plus_user_count].should be_a(Fixnum)
      assigns[:power_user_count].should be_a(Fixnum)
      assigns[:requests].should be_a(Array)
      assigns[:response_times].should be_a(Array)
      assigns[:ttf_request_count].should be_a(Fixnum)
      assigns[:otf_request_count].should be_a(Fixnum)
      assigns[:eot_request_count].should be_a(Fixnum)
      assigns[:woff_request_count].should be_a(Fixnum)
      assigns[:svg_request_count].should be_a(Fixnum)
    end
  end
end
