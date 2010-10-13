class PasswordsController < ApplicationController
  layout 'standard'
  ssl_required :new, :create, :edit, :update

  def new
    @user = User.new
  end

  def create
    if @user = User.find_by_email(params[:user][:email])
      Resque.enqueue(MailJob, :user, :password_reset, @user.id)
    else
      @user = User.new(params[:user])
      @user.errors.add(:email, 'could not be found')
      render :template => 'passwords/new'
    end
  end

  def edit
    unless params[:token].blank?
      @token = params[:token]
      @user = User.find_by_perishable_token(@token)
    else
      @user = current_user
    end
  end

  def update
    unless params[:token].blank?
      @token = params[:token]
      @user = User.find_using_perishable_token(@token)
    else
      @user = current_user
    end

    if @user.update_attributes(params[:user])
      @user.reset_perishable_token!
      flash[:notice] = @token ? 'Your password has been changed.' : 'Your account has been successfully updated.'
      redirect_to @token ? login_url : account_url
    else
      render :template => 'passwords/edit', :status => :unprocessable_entity
    end
  end
end
