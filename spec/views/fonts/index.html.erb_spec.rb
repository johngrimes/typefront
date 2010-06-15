require 'spec_helper'

describe 'fonts/index.html.erb' do
  before do
    login users(:bob)
    assigns[:font] = Font.new
  end

  it 'should render successfully with a list of fonts' do
    assigns[:fonts] = Font.paginate_all_by_user_id(
      users(:bob).id,
      :page => 1,
      :per_page => 5,
      :order => 'name ASC')
    render 'fonts/index', :layout => 'standard'
    response.should be_success
  end

  it 'should render successfully with no fonts' do
    assigns[:fonts] = WillPaginate::Collection.new(1, 5).replace([])
    render 'fonts/index', :layout => 'standard'
    response.should be_success
  end
end
