class UsersController < ApplicationController
  layout 'standard'
  before_filter :require_user, :except => [ :new, :create ]

  def new
    @user = User.new
    @user.subscription_level = params[:subscription_level].to_i
    @user.populate_subscription_fields
  end

  def create
    @user = User.new(params[:user])

    if !check_terms_accepted
      render :action => 'new'
    elsif @user.save
      flash[:notice] = "Successfully created user."
      redirect_to home_path
    else
      render :action => 'new'
    end
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
end
