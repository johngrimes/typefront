require 'spec_helper'

describe StatsController do
  describe 'index action' do
    before do
      fake_result = [{
        'date' => '2010-01-01',
        'users' => '50',
        'requests' => '20000'
      }]
      User.connection.expects(:select_all).at_least_once.returns(fake_result)
    end

    it 'should be successful' do
      get :index
      response.should be_success
    end
  end
end
