require 'spec_helper'

describe 'fonts/demo.html.haml' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
  end

  it 'should render successfully' do
    render 'fonts/demo', :layout => 'blank'
    response.should be_success
  end
end
