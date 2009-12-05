class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [ :create ]

  def create
    custom = CGI::parse(params['custom'])
    PaymentNotification.create!(:params => params,
                                :user_id => custom['user'],
                                :transaction_id => params['txn_id'],
                                :transaction_type => params['txn_type'],
                                :status => params['payment_status'])
    render :nothing => true
  end
end
