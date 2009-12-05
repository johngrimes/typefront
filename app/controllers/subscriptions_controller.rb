class SubscriptionsController < ApplicationController
  include PaypalUrlHelper
  layout 'standard'

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
    redirect_to paypal_modify_subscription_url(current_user, params[:user][:subscription_level])
  end
end
