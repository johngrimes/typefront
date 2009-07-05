module Authentication

  # Registers current_<%= user_singular_name %> and logged_in as helper methods
  # for any controller that includes this module.
  def self.included(controller)
    controller.send :helper_method, :current_<%= user_singular_name %>, :logged_in?
    controller.filter_parameter_logging :password
  end

  # Returns the currently logged in user.
  def current_<%= user_singular_name %>
    @current_<%= user_singular_name %> ||= <%= user_class_name %>.find(session[:<%= user_singular_name %>_id]) if session[:<%= user_singular_name %>_id]
  end

  # Returns true or false depending on whether a user is currently logged in or
  # not.
  def logged_in?
    current_<%= user_singular_name %>
  end

  # Filter method for use in ensuring that a user is logged in.
  def login_required
    unless logged_in?
      flash[:error] = "You must first log in or sign up to do that."
      redirect_to login_url
    end
  end
end
