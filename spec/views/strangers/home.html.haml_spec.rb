require 'spec_helper'

describe 'strangers/home.html.haml' do
  it 'should render successfully' do
    render 'strangers/home', :layout => 'blank'
    response.should be_success
  end
end

