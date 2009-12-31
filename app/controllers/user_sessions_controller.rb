class UserSessionsController < ApplicationController
  layout 'standard'

  def new
    @session = UserSession.new
    @session.remember_me = true
  end

  def create
    @session = UserSession.new(params[:user_session])

    if @session.save
      flash[:notice] = "You are now logged in."
      redirect_back_or_default home_path
    else
      render :action => 'new'
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "You are now logged out."
    redirect_to home_path
  end
end
