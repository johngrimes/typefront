class SubscriptionsController < ApplicationController
  layout 'standard'
  ssl_required :index
  before_filter :require_user

  def index
    @changing_plans = true
    @user = current_user
    render :template => 'strangers/pricing', :layout => 'blank'
  end
end
