class StrangersController < ApplicationController
  layout 'blank'

  def home
    if current_user
      @fonts = Font.paginate_all_by_user_id(
        current_user.id,
        :page => params[:page],
        :per_page => 5,
        :order => 'font_family')
      @font = Font.new
      render :template => 'fonts/index', :layout => 'standard'
    end
  end

  def features
    render :action => :features, :layout => 'standard'
  end

  def pricing
  end

  def terms
  end

  def contact
    render :action => :contact, :layout => 'standard'
  end
end
