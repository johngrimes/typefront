require 'spec_helper'

describe 'fonts/show.js.erb' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
    assigns[:active_tab] = 'information'
  end

  it 'should render successfully' do
    render 'fonts/show.js.erb'
    response.should be_success
  end
end
