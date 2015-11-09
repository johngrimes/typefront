class UsersController < ApplicationController
  layout 'standard'
  ssl_required :new, :create, :activate, :show, :edit, :update, :destroy
  before_filter :require_user, :except => [ :new, :create, :activate ]
  protect_from_forgery :only => [ :new, :create ]

  def new
    redirect_to '/end'
  end

  def create
    redirect_to '/end'
  end

  def activate
    redirect_to '/end'
  end

  def show
    @user = current_user
  end

  def edit
    @user = current_user
    @user.card_type, @user.card_name, @user.card_expiry = nil
  end

  def update
    @user = current_user
    @user.card_validation_on = true
    subscription_level = params[:user][:subscription_level] || nil
    user_was_on_free_plan = (@user.on_free_plan? && subscription_level.to_i != User::FREE)
    just_upgraded = @user.subscription_level < subscription_level.to_i ?
      User::PLANS[subscription_level.to_i][:name].underscore : false

    if @user.update_attributes(params[:user])
      @user.update_gateway_customer
      @user.process_billing(:skip_trial_period => true) if user_was_on_free_plan
      flash[:notice] = 'Your account has been successfully updated.'
      redirect_to just_upgraded ? account_url(:just_upgraded => just_upgraded) : account_url
    else
      render :template => "users/edit", :status => :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user == current_user
      current_user_session.destroy
      @user.destroy
      redirect_to root_path
    else
      raise PermissionDenied, 'You do not have permission to perform that action'
    end
  end

  protected

  def check_subscription_level(level)
    if level < 0 || level > (User::PLANS.size - 1)
      raise ActiveRecord::RecordNotFound
    end
  end
end
