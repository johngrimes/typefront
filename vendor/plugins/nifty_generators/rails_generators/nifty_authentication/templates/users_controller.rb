class <%= user_plural_class_name %>Controller < ApplicationController

  # Responds with a form to sign up.
  # Route:: GET /signup
  def new
    @<%= user_singular_name %> = <%= user_class_name %>.new
  end

  # Creates a new user.
  # Route:: POST /users
  def create
    @<%= user_singular_name %> = <%= user_class_name %>.new(params[:<%= user_singular_name %>])
    if @<%= user_singular_name %>.save
      session[:<%= user_singular_name %>_id] = @<%= user_singular_name %>.id
      flash[:notice] = "Thank you for signing up! You are now logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end
