require 'spec_helper'

describe 'stats/index.html.haml' do
  before do
    activate_authlogic
    assigns[:total_users_url], 
      assigns[:plan_breakdown_url], 
      assigns[:requests_url] = 'http://somedomain.com/chart.png'
  end

  it 'should render successfully' do
    render 'stats/index', :layout => 'standard'
    response.should be_success
  end
end

