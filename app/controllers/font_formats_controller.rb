class FontFormatsController < ApplicationController
  before_filter :require_user

  def update
    @font_format = current_user.font_formats.find(params[:id])
    @font = @font_format.font
    if @font_format.update_attributes(params[:font_format])
      respond_to do |format|
        format.html { redirect_to @font }
        format.js
        format.json do 
          flash[:notice] = 'Successfully updated active status of font format.'
          render :template => 'fonts/show.json.erb'
        end
      end
    else
      respond_to do |format|
        format.html { render :template => 'fonts/show' }
        format.js
        format.json { render :json => @font_format.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end
end
