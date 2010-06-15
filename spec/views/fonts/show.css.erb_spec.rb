require 'spec_helper'

describe 'fonts/show.css.erb' do
  before do
    assigns[:font] = fonts(:duality)
  end

  it 'should render successfully' do
    render 'fonts/show.css.erb'
    response.should be_success
  end
end
