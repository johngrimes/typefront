class <%= sessions_class_name %>Controller < ApplicationController

  # Responds with a login form to create a new user session.
  # Route:: GET /login
  def new
  end

  # Creates a new user session.
  # Parameters:: login, password
  # Route:: POST /sessions
  def create
    <%= user_singular_name %> = <%= user_class_name %>.authenticate(params[:login], params[:password])
    if <%= user_singular_name %>
      session[:<%= user_singular_name %>_id] = <%= user_singular_name %>.id
      flash[:notice] = "Logged in successfully."
      redirect_to root_url
    else
      flash.now[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end

  # Ends a user session.
  # Route:: GET /logout
  def destroy
    session[:<%= user_singular_name %>_id] = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
end
