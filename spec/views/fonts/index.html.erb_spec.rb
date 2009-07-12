require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/fonts/index" do
  fixtures :all

  before do
    login users(:bob)
    assigns[:fonts] = Font.paginate_all_by_user_id(
      users(:bob).id,
      :page => 1,
      :per_page => 5,
      :order => 'name ASC')
    assigns[:font] = Font.new
    render 'fonts/index', :layout => 'standard'
  end

  it 'should spit out valid XHTML' do
    response.should be_valid_xhtml
  end
end
