require 'spec_helper'

describe 'fonts/show.html.haml' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
    assigns[:formats] = fonts(:duality).font_formats.collect { |x| x.file_extension }
    assigns[:tabs] = [['information', 'Font information'], 
      ['example-code', 'Example code'], 
      ['allowed-domains', 'Allowed domains']]
  end

  it 'should render font information successfully' do
    assigns[:active_tab] = 'information'
    render 'fonts/show', :layout => 'standard'
    assert_select '#font-attributes-font-family', /Font family:\nDuality/
    assert_select '#font-attributes-font-subfamily', /Font subfamily:\nRegular/
    assert_select '#font-attributes-vendor-url a[href=?]', 'http://www.somedomain.com'
    response.should be_success
  end

  it 'should render example code successfully' do
    assigns[:active_tab] = 'example-code'
    render 'fonts/show', :layout => 'standard'
    response.should be_success
  end

  it 'should render allowed domains successfully' do
    assigns[:active_tab] = 'allowed-domains'
    render 'fonts/show', :layout => 'standard'
    response.should be_success
  end
end
