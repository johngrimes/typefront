require 'spec_helper'

describe 'strangers/features.html.erb' do
  before do
    activate_authlogic
  end

  it 'should render successfully' do
    render 'strangers/features', :layout => 'standard'
    response.should be_success
  end
end
