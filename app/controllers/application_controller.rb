# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user, :current_user_session

  before_filter :activate_authlogic

  protect_from_forgery
  filter_parameter_logging :password

  #TODO: Add OAuth to RESTful API

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
  end

  def oauthed
    valid = OAuth::Signature.verify(request) do |request_proxy|
      request_proxy = request_proxy
      user = User.find_by_oauth_key(request_proxy.oauth_consumer_key)
      [nil, user.oauth_secret]
    end
  rescue OAuth::RequestProxy::UnknownRequestType
    return false
  end

  def require_user
    unless current_user || oauthed
      store_location
      flash[:notice] = "You must be logged in to access this page."
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page."
      redirect_to home_url
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
end
