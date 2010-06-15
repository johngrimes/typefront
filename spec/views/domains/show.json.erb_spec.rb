require 'spec_helper'

describe 'domains/show.json.erb' do
  before do
    activate_authlogic
    assigns[:domain] = domains(:typefront)
    flash[:notice] = 'Some notice.'
  end

  it 'should render successfully' do
    render 'domains/show.json.erb'
    response.should be_success
  end
end
