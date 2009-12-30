class FontsController < ApplicationController
  layout 'standard'
  before_filter :require_user, :except => [ :show ]

  def index
    @font = Font.new

    respond_to do |format|
      format.html {
        @fonts = Font.paginate_all_by_user_id(
          current_user.id,
          :page => params[:page],
          :per_page => 5,
          :order => 'name ASC')
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
        require_user
        @new_domain = Domain.new
      }
      format.json { require_user }
      format.otf {
        authorise_font_download
        log_request @font, @font.user, @action_name, 
          :remote_ip => request.remote_ip,
          :referer => request.headers['Referer'],
          :origin => request.headers['Origin'],
          :user_agent => request.headers['User-Agent']
        send_file @font.format(:otf).distribution.path,
          :type => 'font/otf'
      }
      format.woff {
        authorise_font_download
        log_request @font, @font.user, @action_name, 
          :remote_ip => request.remote_ip,
          :referer => request.headers['Referer'],
          :origin => request.headers['Origin'],
          :user_agent => request.headers['User-Agent']
        send_file @font.format(:woff).distribution.path,
          :type => 'font/woff'
      }
      format.eot {
        authorise_font_download
        log_request @font, @font.user, @action_name, 
          :remote_ip => request.remote_ip,
          :referer => request.headers['Referer'],
          :origin => request.headers['Origin'],
          :user_agent => request.headers['User-Agent']
        send_file @font.format(:eot).distribution.path,
          :type => 'font/eot'
      }
    end
  end

  def create
    @font = Font.new(params[:font])
    @font.user = current_user

    if @font.save
      flash[:notice] = "Successfully created font."
      respond_to do |format|
        format.html { redirect_to home_url }
        format.json { render :json => { :notice => flash[:notice] }.to_json }
      end
    else
      respond_to do |format|
        format.html {
          @fonts = Font.paginate_all_by_user_id(
            current_user.id,
            :page => 1,
            :per_page => 5,
            :order => 'name ASC')
          render :template => 'fonts/index', :status => :unprocessable_entity
        }
        format.json { render :json => @font.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @font = Font.find(params[:id])

    if params[:new_domains]
      params[:new_domains].split("\n").each do |new_domain|
        @font.domains << Domain.new(:domain => new_domain.strip)
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
        format.html { render :template => 'fonts/show', :status => :unprocessable_entity }
        format.json { render :json => @font.errors.to_json, :status => :unprocessable_entity }
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
    referer = request.headers['Referer']
    origin = request.headers['Origin']

    allowed_domains = @font.domains.collect { |domain| domain.domain }
    origin_allowed = !origin.blank? && allowed_domains.include?(origin)
    referer_allowed = !referer.blank? && !allowed_domains.select { |x| referer.index(x) }.blank?
    current_user_owner = current_user && current_user.fonts.include?(@font)

    unless current_user_owner || origin_allowed || referer_allowed
      raise PermissionDenied, 'You do not have permission to access this resource'
    end

    if origin_allowed
      response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
    end
  end
end
