class UserSessionsController < ApplicationController
  layout 'standard'
  ssl_required :new, :create

  def new
    @session = UserSession.new
    @session.remember_me = true
  end

  def create
    @session = UserSession.new(params[:user_session])

    if @session.save
      flash[:notice] = "You are now logged in."
      redirect_back_or_default fonts_url
    else
      render :action => 'new'
    end
  end

  def destroy
    current_user_session.destroy if current_user_session
    flash[:notice] = "You are now logged out."
    redirect_to root_url
  end
end
