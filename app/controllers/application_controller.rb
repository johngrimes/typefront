# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement

  helper :all
  helper_method :current_user, :current_user_session

  before_filter :activate_authlogic

  filter_parameter_logging :password, :password_confirmation, :card_number, :card_verification

  protected

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
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
      respond_to do |format|
        format.html { render :file => "#{RAILS_ROOT}/public/403.html", :status => :forbidden }
        format.json {
          error = { 
            :request => request.path,
            :error => exception.message
          }
          render :json => error, :status => :forbidden
        }
        format.otf {
          error = { 
            :request => request.path,
            :error => exception.message
          }
          response.headers['Content-Type'] = 'application/json; charset=utf-8'
          render :json => error, :status => :forbidden
        }
        format.woff {
          error = { 
            :request => request.path,
            :error => exception.message
          }
          response.headers['Content-Type'] = 'application/json; charset=utf-8'
          render :json => error, :status => :forbidden
        }
        format.eot {
          error = { 
            :request => request.path,
            :error => exception.message
          }
          response.headers['Content-Type'] = 'application/json; charset=utf-8'
          render :json => error, :status => :forbidden
        }
      end
    else
      super
    end
  end

  def local_request?
    false
  end
end
