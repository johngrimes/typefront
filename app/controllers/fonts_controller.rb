class FontsController < ApplicationController
  layout 'standard'
  before_filter :require_user, :except => [ :show ]

  def index
    @font = current_user.fonts.build

    respond_to do |format|
      format.html {
        @fonts = Font.paginate_all_by_user_id(
          current_user.id,
          :page => params[:page],
          :per_page => 5,
          :order => 'font_family')
      }
      format.css {
        @fonts = Font.find_all_by_user_id(current_user.id)
      }
      format.json {
        @fonts = Font.find_all_by_user_id(current_user.id, :order => 'id ASC')
      }
    end
  end

  def show
    @font = Font.find(params[:id])

    respond_to do |format|
      format.html { 
        require_font_owner
        @formats = @font.formats.collect { |x| x.file_extension }
        @new_domain = Domain.new
      }
      format.json { require_font_owner }

      Font::AVAILABLE_FORMATS.each do |available_format|
        format.send(available_format) {
          authorise_font_download
          @font.log_request @action_name,
            :remote_ip => request.remote_ip,
            :referer => request.headers['Referer'],
            :origin => request.headers['Origin'],
            :user_agent => request.headers['User-Agent']
          send_file @font.format(available_format).distribution.path,
            :type => "font/#{available_format}"
        }
      end
    end
  end

  def demo
    @font = Font.find(params[:id])
    render :layout => 'blank'
  end

  def create
    @font = current_user.fonts.build(params[:font])

    if @font.save
      flash[:notice] = "Successfully created font."
      respond_to do |format|
        format.html { redirect_to home_url }
        format.json { render :template => 'fonts/show.json.erb' }
      end
    else
      respond_to do |format|
        format.html {
          @fonts = Font.paginate_all_by_user_id(
            current_user.id,
            :page => 1,
            :per_page => 5,
            :order => 'font_family')
          render :template => 'fonts/index', :status => :unprocessable_entity
        }
        format.json { render :json => @font.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @font = current_user.fonts.find(params[:id])

    if params[:new_domains]
      params[:new_domains].split("\n").each do |new_domain|
        @font.domains << Domain.new(:domain => new_domain.strip)
      end
    end

    if @font.update_attributes(params[:font])
      flash[:notice] = "Successfully updated font."
      redirect_to @font
    else
      @formats = @font.formats
      render :template => 'fonts/show', :status => :unprocessable_entity
    end
  end

  def destroy
    @font = current_user.fonts.find(params[:id])
    @font.destroy
    flash[:notice] = "Successfully removed font."
    respond_to do |format|
      format.html { redirect_to home_url }
      format.json { render :json => { :notice => flash[:notice] }.to_json }
    end
  end

  protected

  def require_font_owner
    unless current_user == @font.user
      raise PermissionDenied, 'You do not have permission to access this resource'
    end
  end

  def authorise_font_download
    referer = request.headers['Referer']
    origin = request.headers['Origin']

    allowed_domains = @font.domains.collect { |domain| domain.domain }.push($HOST).push($HOST_SSL)
    origin_allowed = !origin.blank? && allowed_domains.include?(origin)
    referer_allowed = !referer.blank? && !allowed_domains.select { |x| referer.index(x) }.blank?

    unless origin_allowed || referer_allowed
      raise PermissionDenied, 'You do not have permission to access this resource'
    end

    if origin_allowed
      response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
    end
  end
end
