class FontsController < ApplicationController
  layout 'standard'
  ssl_allowed :show
  before_filter :require_user, :except => [ :show ]
  before_filter :check_upload_allowed, :only => [ :index ]
  around_filter :log_request, :only => :show

  def index
    @font = current_user.fonts.build if @allow_upload

    respond_to do |format|
      format.html {
        @fonts = Font.paginate_all_by_user_id(
          current_user.id,
          :page => params[:page],
          :per_page => 10,
          :order => 'font_family')
      }
      format.css {
        @fonts = current_user.ready_fonts
      }
      format.json {
        @fonts = current_user.fonts.find(:all, :order => 'id ASC')
      }
    end
  end

  def show
    @font = Font.find(params[:id])
    if @font.generate_jobs_pending > 0
      require_font_owner
      redirect_to processing_font_url(@font)
    end

    respond_to do |format|
      format.html { 
        require_font_owner
        get_active_tab
        @formats = @font.font_formats.present.active.collect { |x| x.file_extension }
      }
      format.js {
        require_font_owner
        get_active_tab
        @formats = @font.font_formats.present.active.collect { |x| x.file_extension }
      }
      format.json { require_font_owner }
      format.css

      Font::AVAILABLE_FORMATS.each do |available_format|
        format.send(available_format) {
          authorise_font_download
          if @requested_format = @font.format(available_format, :ignore_inactive => @typefront_request, :raise_error => true)
            if modified_since
              send_file @requested_format.distribution.path,
                :type => Mime::Type.lookup_by_extension(available_format.to_s)
            else
              render :nothing => true, :status => 304
            end
          else
            raise PermissionDenied, 'You do not have permission to access this resource'
          end
        }
      end
    end
  end

  def demo
    @font = Font.ready.find(params[:id])
    require_font_owner
    render :layout => 'blank'
  end

  def processing
    @font = current_user.fonts.find(params[:id])
    redirect_to font_url(@font) if @font.generate_jobs_pending == 0
  end

  def create
    @font = current_user.fonts.build(params[:font])

    if @font.save
      respond_to do |format|
        format.html { redirect_to @font }
        format.json { render :template => 'fonts/show.json.erb' }
      end
    else
      respond_to do |format|
        format.html {
          @fonts = Font.paginate_all_by_user_id(
            current_user.id,
            :page => 1,
            :per_page => 10,
            :order => 'font_family')
          check_upload_allowed
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
      respond_to do |format|
        format.html do
          flash[:notice] = "Successfully updated font."
          redirect_to @font
        end
        format.js
      end
    else
      respond_to do |format|
        format.html do
          get_active_tab
          @formats = @font.font_formats.active.collect { |x| x.file_extension }
          render :template => 'fonts/show', :status => :unprocessable_entity
        end
        format.js
      end
    end
  end

  def destroy
    @font = current_user.fonts.find(params[:id])
    @font.destroy
    flash[:notice] = "Successfully removed font."
    respond_to do |format|
      format.html { redirect_to fonts_url }
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

    typefront_domains = [$HOST, $HOST_SSL]
    allowed_domains = @font.domains.collect { |domain| domain.domain } + typefront_domains

    origin_allowed = !origin.blank? && allowed_domains.include?(origin)
    referer_allowed = !referer.blank? && !allowed_domains.select { |x| referer.index(x) }.blank?
    wildcard_domain = allowed_domains.include?('*')

    @typefront_request = (!origin.blank? && typefront_domains.include?(origin)) || (!referer.blank? && !typefront_domains.select { |x| referer.index(x) }.blank?)

    unless origin_allowed || referer_allowed || wildcard_domain
      raise PermissionDenied, 'You do not have permission to access this resource'
    end

    if origin_allowed
      response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
    elsif wildcard_domain
      response.headers['Access-Control-Allow-Origin'] = '*'
    end
  end

  def check_upload_allowed
    @allow_upload = current_user.fonts.size < current_user.fonts_allowed
  end

  def modified_since
    modified_at = @requested_format.updated_at || @requested_format.created_at
    request_date = Time.parse(request.env['HTTP_IF_MODIFIED_SINCE']) unless request.env['HTTP_IF_MODIFIED_SINCE'].blank?
    request_date.nil? ? true : modified_at > request_date
  end

  def log_request
    @start_time = Time.now
    yield
    log_font_request
  end

  def get_active_tab
    @tabs = [['information', 'Font information'], 
      ['example-code', 'Example code'], 
      ['allowed-domains', 'Allowed domains']]
    if @tabs.collect { |x| x[0] }.include?(params[:tab_name])
      @active_tab = params[:tab_name]
    else
      @active_tab = 'information'
    end
  end
end
