require 'spec_helper'

describe 'fonts/show.html.haml' do
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

  it 'should render font information properly' do
    render 'fonts/show', :layout => 'standard'
    assert_select '#font-attributes p', "Font family:\n    Duality"
    assert_select '#font-attributes p', "Font subfamily:\n    Regular"
    assert_select '#font-attributes p a[href=?]', 'http://www.somedomain.com'
  end
end
