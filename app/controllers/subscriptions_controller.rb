class SubscriptionsController < ApplicationController
  layout 'standard'
  ssl_required :edit, :update
  before_filter :require_user

  def edit
    @changing_plans = true
    @user = current_user
    render :template => 'strangers/pricing', :layout => 'blank'
  end

  def update
    @subscription_level = params[:user][:subscription_level]

    if current_user.subscription_level == User::FREE || current_user.gateway_customer_id.blank?
      @user = current_user
      @user.card_type, @user.card_name, @user.card_expiry = nil
      render :template => 'users/edit', :layout => 'standard'
    else
      current_user.update_attributes!(:subscription_level => @subscription_level)
      flash[:notice] = "You are now on the #{current_user.subscription_name} plan."
      redirect_to account_url
    end
  end
end
