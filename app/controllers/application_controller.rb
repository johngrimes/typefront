# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'log_event'

class ApplicationController < ActionController::Base
  include SslRequirement, ExceptionNotifiable
  include LogEvent

  helper :all
  helper_method :current_user, :current_user_session

  before_filter :activate_authlogic

  filter_parameter_logging :password, :password_confirmation,
    :card_name, :card_number, :card_verification, :card_expiry

  protected

  def current_user
    @current_user = current_user_session && current_user_session.record
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def require_user
    unless current_user
      store_location

      respond_to do |format|
        format.html {
          flash[:notice] = "You must be logged in to access this page."
          redirect_to login_url
        }
        format.json {
          response.headers['WWW-Authenticate'] = 'Basic realm="TypeFront API"'
          error = {
            :request => request.path,
            :error => 'You must be authenticated to access this resource.'
          }
          render :json => error, :status => 401
        }
      end

      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def rescue_action(exception)
    case exception
    when PermissionDenied
      log_font_request(true)
      respond_to do |format|
        format.html { render :file => "#{RAILS_ROOT}/public/403.html", :status => :forbidden }
        format.json {
          error = {
            :request => request.path,
            :error => exception.message
          }
          render :json => error, :status => :forbidden
        }
        Font::AVAILABLE_FORMATS.each do |available_format|
          format.send(available_format) {
            error = {
              :request => request.path,
              :error => exception.message
            }
            response.headers['Content-Type'] = 'application/json; charset=utf-8'
            render :json => error, :status => :forbidden
          }
        end
      end
    else
      super
    end
  end

  def api_call?
    params[:format] == 'json' || request.accepts.include?('application/json')
  end

  def ssl_required_with_env_check?
    if RAILS_ENV == 'production' && (ssl_required_without_env_check? || api_call?)
      true
    else
      false
    end
  end
  alias_method_chain :ssl_required?, :env_check

  def header_block
    headers = request.env.inject({}) { |h, (k, v)|
      if k =~ /^(HTTP|CONTENT)_/ then
        h[k.sub(/^HTTP_/, '').dasherize.gsub(/([^\-]+)/) { $1.capitalize }] = v
      end
      h
    }
    header_string = ''
    headers.each do |header, value|
      header_string << "#{header}: #{value}\n"
    end
    return header_string
  end

  def log_font_request(rejected = false)
    if @font
      @font.log_request @action_name,
        :format => params[:format].blank? ? nil : params[:format].to_sym,
        :remote_ip => request.remote_ip,
        :referer => request.headers['Referer'],
        :origin => request.headers['Origin'],
        :user_agent => request.headers['User-Agent'],
        :response_time => (@start_time ? Time.now - @start_time : nil),
        :rejected => rejected
    end
  end
end
