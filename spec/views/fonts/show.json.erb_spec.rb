require 'spec_helper'

describe 'fonts/show.json.erb' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
    flash[:notice] = 'Some notice.'
  end

  it 'should render successfully' do
    render 'fonts/show.json.erb'
    response.should be_success
  end
end
