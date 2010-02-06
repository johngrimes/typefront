class UsersController < ApplicationController
  layout 'standard'
  ssl_required :new, :create, :activate, :show, :edit, :update, :destroy
  before_filter :require_user, :except => [ :new, :create, :activate ]
  protect_from_forgery :only => [ :new, :create ]

  def new
    @user = User.new
    check_subscription_level(params[:subscription_level].to_i) 
    @user.subscription_level = params[:subscription_level].to_i
    @user.populate_subscription_fields
    @user.terms = false
  end

  def create
    @user = User.new(params[:user])
    @user.active = !@user.on_free_plan?
    @user.card_validation_on = true

    if @user.save
      if @user.on_free_plan?
        UserMailer.send_later :deliver_activation, @user
        render :template => 'users/activation_instructions'
      else
        flash[:notice] = 'Your new account has been created.'
        redirect_to home_url
      end
      AdminMailer.send_later :deliver_new_user_joined, @user
    else
      @user.populate_subscription_fields
      render :action => 'new', :status => :unprocessable_entity
    end
  end

  def activate
    @user = User.find_by_perishable_token(params[:code])

    if @user
      @user.update_attribute(:active, true)
      UserSession.create(@user)
      flash[:notice] = 'Your account is now active. Welcome to TypeFront!'
      redirect_to home_url
    else
      flash[:notice] = 'The activation code you supplied does not appear to be valid. It may have expired. Please get in touch at contact@typefront.com.'
      redirect_to login_url
    end
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
    user_was_on_free_plan = (@user.on_free_plan? && params[:user][:subscription_level] != User::FREE)

    if @user.update_attributes(params[:user])
      @user.update_gateway_customer
      @user.process_billing(:skip_trial_period => true) if user_was_on_free_plan
      flash[:notice] = 'Your account has been successfully updated.'
      redirect_to account_url
    else
      render :template => "users/edit", :status => :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    
    if @user == current_user
      current_user_session.destroy
      @user.destroy
      redirect_to home_url
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
