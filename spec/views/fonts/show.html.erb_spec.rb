require 'spec_helper'

describe 'fonts/show.html.erb' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
    assigns[:formats] = fonts(:duality).formats
    assigns[:new_domain] = Domain.new
  end

  it 'should render successfully' do
    render 'fonts/show', :layout => 'standard'
    response.should be_success
  end
end
