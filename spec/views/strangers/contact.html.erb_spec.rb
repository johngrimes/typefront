require 'spec_helper'

describe 'strangers/contact.html.erb' do
  before do
    activate_authlogic
  end

  it 'should render successfully' do
    render 'strangers/contact', :layout => 'standard'
    response.should be_success
  end
end
