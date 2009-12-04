class UsersController < ApplicationController
  layout 'standard'
  ssl_required :new, :create if Rails.env.production?
  before_filter :require_user, :except => [ :new, :create, :activate, :signup_success, :signup_cancel ]

  def new
    @user = User.new
    @user.subscription_level = params[:subscription_level].to_i
    @user.populate_subscription_fields
  end

  def create
    @user = User.new(params[:user])

    if !check_terms_accepted
      render :action => 'new', :status => :unprocessable_entity
    elsif @user.save
      if @user.on_free_plan?
        UserMailer.deliver_activation(@user)
        render :template => 'users/activation_instructions'
      else
        redirect_to paypal_subscribe_url(@user)
      end
    else
      @user.populate_subscription_fields
      render :action => 'new', :status => :unprocessable_entity
    end
  end

  def activate
    @user = User.find_by_perishable_token(params[:code])

    if @user
      @user.update_attribute(:active, true)
      flash[:notice] = 'Your account is now active. To get started, please login using your email and password.'
      redirect_to login_url
    else
      flash[:notice] = 'The activation code you supplied does not appear to be valid. It may have expired. Please get in touch at contact@typefront.com.'
      redirect_to login_url
    end
  end

  def signup_success
    flash[:notice] = 'Your subscription is complete. To get started, please login using your email and password.'
    redirect_to login_url
  end

  def signup_cancel
  end

  def show
    @user = current_user
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = "You are now on the #{@user.subscription_name} plan." + (@user.subscription_level > 0 ? " Your next invoice will be for the new amount of US$#{@user.subscription_amount}." : '')
      redirect_to account_url
    else
      render :template => "users/show", :status => :unprocessable_entity
    end
  end

  def select_plan
    @changing_plans = true
    @user = current_user
    render :template => 'strangers/pricing', :layout => 'blank'
  end

  def destroy
    @user = User.find(params[:id])
    
    if @user == current_user
      current_user_session.destroy
      @user.destroy
    end
    
    redirect_to home_url
  end

  protected

  def check_terms_accepted
    @accept_terms = params[:accept_terms]
    unless @accept_terms
      @user.errors.add :accept_terms, 'must be accepted before you can create an account'
      return false
    else
      return true
    end
  end

  def paypal_subscribe_url(user)
    values = {  :cmd => '_s-xclick',
                :hosted_button_id => PAYPAL_CONFIG[:button_id][user.subscription_name.downcase],
                :custom => user.id }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end
end
