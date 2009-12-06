class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [ :create ]

  def create
    custom = CGI::parse(params['custom'])
    
    pn = PaymentNotification.new
    pn.params = params
    pn.transaction_id = params['txn_id']
    pn.transaction_type = params['txn_type']
    pn.status = params['payment_status']

    pn.user_id = custom['user'].first
    pn.subscription_level = custom['subscription_level'].first.to_i
    pn.delete_account = (custom['delete_account'].first.to_i == 1 ? true : false)

    pn.save!
    render :nothing => true
  end
end
