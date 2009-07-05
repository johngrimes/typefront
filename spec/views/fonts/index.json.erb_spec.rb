require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/fonts/index.json" do
  fixtures :all

  before do
    login users(:bob)
    assigns[:fonts] = users(:bob).fonts
    render 'fonts/index.json.erb', :layout => 'standard'
  end

  it 'should be successful' do
    response.should be_success
  end
end
