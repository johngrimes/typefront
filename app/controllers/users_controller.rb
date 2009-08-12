class UsersController < ApplicationController
  layout 'standard'
  before_filter :require_user, :only => [ :show ]

  def new
    @user = User.new
    @subscription_level = params[:subscription_level]
    case @subscription_level.to_i
    when User::BUSINESS
      @subscription_description = 'Business'
      @subscription_amount = 'US$899'
    when User::POWER
      @subscription_description = 'Power'
      @subscription_amount = 'US$35'
    when User::PLUS
      @subscription_description = 'Plus'
      @subscription_amount = 'US$15'
    when User::BASIC
      @subscription_description = 'Basic'
      @subscription_amount = 'US$5'
    end
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
