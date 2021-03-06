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
    @user = current_user
    @subscription_level = params[:user][:subscription_level].to_i
    user_was_on_paying_plan = !@user.on_free_plan? && @subscription_level == User::FREE
    just_upgraded = @user.subscription_level < @subscription_level ? 
      User::PLANS[@subscription_level][:name].underscore : false

    if @user.subscription_level == User::FREE || @user.gateway_customer_id.blank?
      @user.card_type, @user.card_name, @user.card_expiry = nil
      render :template => 'users/edit', :layout => 'standard'
    else
      @user.update_attribute(:subscription_level, @subscription_level)
      if @user.on_free_plan? && user_was_on_paying_plan
        @user.clear_all_billing
      end
      @user.clip_fonts_to_plan_limit
      flash[:notice] = "You are now on the #{@user.subscription_name} plan."
      redirect_to just_upgraded ? account_url(:just_upgraded => just_upgraded) : account_url
    end
  end
end
