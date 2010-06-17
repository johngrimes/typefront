require 'spec_helper'

describe 'strangers/terms.html.haml' do
  it 'should render successfully' do
    render 'strangers/terms', :layout => 'blank'
    response.should be_success
  end
end

