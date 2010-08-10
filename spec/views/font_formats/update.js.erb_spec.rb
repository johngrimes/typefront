require 'spec_helper'

describe 'font_formats/update.js.erb' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
    assigns[:font_format] = font_formats(:duality_ttf)
  end

  it 'should render successfully' do
    render 'font_formats/update.js.erb'
    response.should be_success
  end
end
