require 'spec_helper'

describe PagesController do
  describe 'show action' do
    before do
      fake_rails_root = "#{Rails.root}/spec/fixtures/pages"
      Rails.expects(:root).at_least_once.returns(fake_rails_root)
    end

    it 'should be successful for a static page written in Markdown' do
      markdown_output = '<p>The <strong>quick</strong> brown fox jumped over the <em>lazy</em> dog.</p>'
      get :show,
        :id => 'some-page'
      assigns[:converted_html].should == markdown_output
      response.should be_success
    end

    it 'should be successful for a template' do
      get :show,
        :id => 'another-page'
      response.should render_template('pages/another_page')
      response.should be_success
    end

    it 'should include the page stylesheet if present' do
      stylesheet_include = '<link href="/stylesheets/pages/page_with_style.css" media="screen" rel="stylesheet" type="text/css" />'
      get :show,
        :id => 'page-with-style'
      assigns[:content_for_styles].should == stylesheet_include
      response.should be_success
    end
  end
end
