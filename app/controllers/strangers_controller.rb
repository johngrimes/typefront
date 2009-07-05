class StrangersController < ApplicationController
  layout 'standard'

  def home
    if current_user
      @fonts = current_user.fonts
      @font = Font.new
      render :template => 'fonts/index'
    end
  end
end
