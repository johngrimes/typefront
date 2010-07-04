require 'spec_helper'

describe 'stats/index.html.haml' do
  before do
    activate_authlogic
    assigns[:unactivated_users_total] = [1, 2, 3]
    assigns[:free_users_total] = [1, 2, 3]
    assigns[:paying_users_total] = [1, 2, 3]
    assigns[:free_users_joined] = [1, 2, 3]
    assigns[:plus_users_joined] = [1, 2, 3]
    assigns[:power_users_joined] = [1, 2, 3]
    assigns[:requests] = [1, 2, 3]
    assigns[:response_times] = [1, 2, 3]
    assigns[:free_user_count],
      assigns[:plus_user_count],
      assigns[:power_user_count],
      assigns[:ttf_request_count],
      assigns[:otf_request_count],
      assigns[:eot_request_count],
      assigns[:woff_request_count],
      assigns[:svg_request_count] = 1
  end

  it 'should render successfully' do
    render 'stats/index', :layout => 'standard'
    response.should be_success
  end
end

