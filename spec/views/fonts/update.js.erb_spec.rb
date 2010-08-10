require 'spec_helper'

describe 'fonts/update.js.erb' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
  end

  it 'should render successfully' do
    render 'fonts/update.js.erb'
    response.should be_success
  end
end
