require 'spec_helper'

describe 'strangers/terms.html.erb' do
  it 'should render successfully' do
    render 'strangers/terms', :layout => 'blank'
    response.should be_success
  end
end

