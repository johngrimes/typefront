require 'spec_helper'

describe 'fonts/index.json.erb' do
  before do
    activate_authlogic
    assigns[:fonts] = users(:bob).fonts
  end

  it 'should render successfully' do
    render 'fonts/index.json.erb'
    response.should be_success
  end
end
