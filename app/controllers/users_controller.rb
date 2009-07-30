class UsersController < ApplicationController
  layout 'standard'
  before_filter :require_user, :only => [ :home ]

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
    if @user.save
      flash[:notice] = "Successfully created user."
      redirect_to home_path
    else
      render :action => 'new'
    end
  end
end
