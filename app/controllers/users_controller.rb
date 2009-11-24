class UsersController < ApplicationController
  layout 'standard'
  before_filter :require_user, :only => [ :show ]

  def new
    @user = User.new
    @subscription_level = params[:subscription_level].to_i
    @subscription_description = User::PLANS[@subscription_level][:name]
    @subscription_amount = User::PLANS[@subscription_level][:amount]
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
