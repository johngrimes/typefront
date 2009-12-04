class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [ :create ]

  def create
    PaymentNotification.create!(:params => params,
                                :user_id => params['custom'],
                                :transaction_id => params['txn_id'],
                                :transaction_type => params['txn_type'],
                                :status => params['payment_status'])
    render :nothing => true
  end
end
