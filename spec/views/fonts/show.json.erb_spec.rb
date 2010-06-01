require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/fonts/show.json" do
  fixtures :all

  before do
    login users(:bob)
    assigns[:font] = fonts(:duality)
    render 'fonts/show.json.erb', :layout => 'standard'
  end

  it 'should be successful' do
    response.should be_success
  end
end
