class UsersController < ApplicationController
  include PaypalUrlHelper
  layout 'standard'
  ssl_required :new, :create, :show, :destroy
  before_filter :require_user, :except => [ :new, :create, :activate, :signup_success, :signup_cancel ]

  def new
    @user = User.new
    @user.subscription_level = params[:subscription_level].to_i
    @user.populate_subscription_fields
  end

  def create
    @user = User.new(params[:user])
    @user.active = !@user.on_free_plan?

    if @user.save
      if @user.on_free_plan?
        UserMailer.deliver_activation(@user)
        render :template => 'users/activation_instructions'
      else
        flash[:notice] = 'As payments are currently in test mode, your account has been automatically activated. You may now log in.'
        redirect_to home_url
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

  def show
    @user = current_user
  end

#   Reset password
#   def update
#     @user = current_user

#     if @user.update_attributes(params[:user])
#       flash[:notice] = 'Your account has been successfully updated.'
#       redirect_to account_url
#     else
#       render :template => "users/show", :status => :unprocessable_entity
#     end
#   end

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
end
