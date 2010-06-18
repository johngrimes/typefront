class PagesController < ApplicationController
  include ActionView::Helpers

  before_filter :check_for_markdown
  caches_page :show

  MARKDOWN_EXTENSIONS = [
    'markdown',
    'mkdn',
    'md',
    'mkd'
  ]

  def show
    apply_page_style
    if @converted_html
      render :text => @converted_html, :layout => 'standard'
    else
      render :template => current_page
    end

  rescue ActionView::MissingTemplate
    render_not_found
  end

  protected

  def check_for_markdown
    MARKDOWN_EXTENSIONS.each do |ext|
      if view_path_exists?("#{current_page}.#{ext}")
        read_view_path("#{current_page}.markdown")
        if @first_line[0..5] == 'Title:'
          @title = @first_line.split(/:\s|\n/)[1]
        end
        doc = Maruku.new(read_view_path("#{current_page}.markdown"))
        @converted_html = doc.to_html
      end
    end
  end

  def current_page
    "pages/#{params[:id].to_s.underscore}"
  end

  def view_path_exists?(path)
    File.exist?(File.join(Rails.root, 'app', 'views', path))
  end

  def read_view_path(path)
    @raw = ''
    File.open(File.join(Rails.root, 'app', 'views', path), 'r') do |file|
      @first_line = file.readline
      @raw = @first_line + file.read
    end
  end

  def apply_page_style
    if File.exist?(File.join(Rails.root, 'public', 'stylesheets', 'pages', "#{params[:id].to_s.underscore}.css"))
      @content_for_styles = stylesheet_link_tag(current_page)
    end
  end    

  def render_not_found
    if File.exist?(File.join(Rails.root, 'public', '404.html'))
      render :file => File.join(Rails.root, 'public', '404.html'), :status => 404
    else
      render :nothing => true, :status => 404
    end
  end
end
