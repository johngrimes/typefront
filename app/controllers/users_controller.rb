class UsersController < ApplicationController
  layout 'standard'
  before_filter :require_user, :only => [ :home ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfully created user."
      redirect_to home_path
    else
      render :action => 'new'
    end
  end
end
