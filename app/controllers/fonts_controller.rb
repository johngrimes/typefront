class FontsController < ApplicationController
  layout 'standard'
  before_filter :require_user, :except => [ :show ]

  def index
    @fonts = Font.find_all_by_user_id(
      current_user.id,
      :order => 'name')
    @font = Font.new

    respond_to do |format|
      format.html
      format.css
      format.json
    end
  end

  def show
    @font = Font.find(params[:id])

    respond_to do |format|
      format.html { 
        require_user
        @new_domain = Domain.new
      }
      format.json
      format.font {
        authorise_font_download
        send_file @font.distribution.path,
          :type => @font.distribution_content_type
      }
    end
  end

  def create
    @font = Font.new(params[:font])
    @font.user = current_user
    @font.domains << Domain.new(:domain => 'localhost')

    if @font.save
      flash[:notice] = "Successfully created font."
      respond_to do |format|
        format.html { redirect_to home_url }
        format.json { render :json => { :notice => flash[:notice] }.to_json }
      end
    else
      respond_to do |format|
        format.html {
          @fonts = current_user.fonts
          render :template => 'fonts/index'
        }
        format.json { render :json => @font.errors.to_json }
      end
    end
  end

  def update
    @font = Font.find(params[:id])

    if params[:new_domains]
      params[:new_domains].split("\n").each do |new_domain|
        @font.domains << Domain.new(:domain => new_domain)
      end
    end

    if @font.update_attributes(params[:font])
      respond_to do |format|
        flash[:notice] = "Successfully updated font."
        format.html { redirect_to @font }
        format.json { render :json => { :notice => flash[:notice] }.to_json }
      end
    else
      respond_to do |format|
        format.html { render :template => 'fonts/show' }
        format.json { render :json => @font.errors.to_json }
      end
    end
  end

  def destroy
    @font = Font.find(params[:id])
    @font.destroy
    flash[:notice] = "Successfully removed font."
    respond_to do |format|
      format.html { redirect_to home_url }
      format.json { render :json => { :notice => flash[:notice] }.to_json }
    end
  end

  protected

  def authorise_font_download
    allowed_domains = @font.domains.collect { |domain| domain.domain }
    origin_allowed = request.headers['Origin'] && allowed_domains.include?(request.headers['Origin'])
    current_user_owner = current_user && current_user.fonts.include?(@font)
    unless current_user_owner || origin_allowed
      raise PermissionDenied, 'You do not have permission to access this resource'
    end
    if origin_allowed
      response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
    end
  end
end
