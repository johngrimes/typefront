class StrangersController < ApplicationController
  layout 'blank'
  ssl_allowed :home, :pricing, :terms

  def home
    if current_user
      @fonts = Font.paginate_all_by_user_id(
        current_user.id,
        :page => params[:page],
        :per_page => 5,
        :order => 'name ASC')
      @font = Font.new
      render :template => 'fonts/index', :layout => 'standard'
    end
  end

  def pricing
  end

  def terms
  end

  def contact
    render :action => :contact, :layout => 'standard'
  end
end
