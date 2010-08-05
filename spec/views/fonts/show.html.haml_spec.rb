require 'spec_helper'

describe 'fonts/show.html.haml' do
  before do
    activate_authlogic
    assigns[:font] = fonts(:duality)
    assigns[:formats] = fonts(:duality).formats
    assigns[:new_domain] = Domain.new
    assigns[:tabs] = [['information', 'Font information'], 
      ['example-code', 'Example code'], 
      ['allowed-domains', 'Allowed domains']]
  end

  it 'should render font information successfully' do
    assigns[:active_tab] = 'information'
    render 'fonts/show', :layout => 'standard'
    assert_select '#font-attributes p', /Font family:\n\s+Duality/
    assert_select '#font-attributes p', /Font subfamily:\n\s+Regular/
    assert_select '#font-attributes p a[href=?]', 'http://www.somedomain.com'
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
