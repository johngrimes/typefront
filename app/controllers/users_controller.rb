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
    @user.reset_perishable_token
    @user.card_validation_on = true

    if @user.save
      log_event('Signed up',
        'Plan' => @user.subscription_name,
        'Amount' => @user.subscription_amount
      )
      if @user.on_free_plan?
        Resque.enqueue(MailJob, :user, :activation, @user.id)
        render :template => 'users/activation_instructions'
      else
        flash[:notice] = 'Your new account has been created.'
        log_event('Activated')
        redirect_to fonts_url(:just_signed_up => @user.subscription_name.underscore)
      end
      Resque.enqueue(MailJob, :admin, :new_user_joined, @user.id)
    else
      @user.populate_subscription_fields
      render :action => 'new', :status => :unprocessable_entity
    end
  end

  def activate
    @user = User.find_by_perishable_token(params[:code])

    if @user
      @user.update_attribute(:active, true)
      @user.reset_perishable_token!
      UserSession.create(@user)
      log_event('Activated')
      flash[:notice] = 'Your account is now active. Welcome to TypeFront!'
      redirect_to fonts_url(:just_activated => @user.subscription_name.underscore)
    else
      flash[:notice] = "The activation code you supplied does not appear to be valid. It may have expired. Please get in touch at #{MAIL_CONFIG[:contact_email]}."
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
    subscription_level = params[:user][:subscription_level] || nil
    user_was_on_free_plan = (@user.on_free_plan? && subscription_level.to_i != User::FREE)
    just_upgraded = @user.subscription_level < subscription_level.to_i ?
      User::PLANS[subscription_level.to_i][:name].underscore : false
    just_downgraded = subscription_level and (@user.subscription_level > subscription_level.to_i ?
      User::PLANS[subscription_level.to_i][:name].underscore : false)

    if @user.update_attributes(params[:user])
      @user.update_gateway_customer
      @user.process_billing(:skip_trial_period => true) if user_was_on_free_plan
      flash[:notice] = 'Your account has been successfully updated.'
      log_event('Upgraded account') if just_upgraded
      log_event('Downgraded account') if just_downgraded
      log_event('Updated billing details') unless just_upgraded or just_downgraded
      redirect_to just_upgraded ? account_url(:just_upgraded => just_upgraded) : account_url
    else
      render :template => "users/edit", :status => :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user == current_user
      log_event('Deleted account')
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
