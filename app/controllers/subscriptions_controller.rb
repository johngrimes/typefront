class SubscriptionsController < ApplicationController
  def index
    @changing_plans = true
    @user = current_user
    render :template => 'strangers/pricing', :layout => 'blank'
  end

  def outcome
    if params[:subscription_action] == 'signup-successful'
      flash[:notice] = 'Your subscription is complete. To get started, please login using your email and password.'
      redirect_to login_url
    else
      render :template => "subscriptions/outcomes/#{params[:subscription_action].sub('-', '_')}"
    end
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      flash[:notice] = "You are now on the #{@user.subscription_name} plan." + (@user.subscription_level > 0 ? " Your next invoice will be for the new amount of US$#{@user.subscription_amount}." : '')
      redirect_to account_url
    else
      render :template => "users/show", :status => :unprocessable_entity
    end
  end
end
