class StrangersController < ApplicationController
  layout 'blank'

  def home
    if current_user
      @fonts = Font.paginate_all_by_user_id(
        current_user.id,
        :page => params[:page],
        :per_page => 5,
        :order => 'name ASC')
      @font = Font.new
      render :template => 'fonts/index'
    end
  end
end
