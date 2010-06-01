require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/fonts/show.css" do
  fixtures :all

  before do
    assigns[:font] = fonts(:duality)
    render 'fonts/show.css.erb'
  end

  it 'should be successful' do
    response.should be_success
  end
end
