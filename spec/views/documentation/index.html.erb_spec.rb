require 'spec_helper'

describe "documentation/index.html.erb" do
  before do
    activate_authlogic
  end

  it 'should render successfully' do
    render 'documentation/index', :layout => 'standard'
    response.should be_success
  end
end
