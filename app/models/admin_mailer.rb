class AdminMailer < ActionMailer::Base
  def new_user_joined(user)
    @user = user

    subject 'New user joined'
    recipients "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def payment_received(invoice)
    @user, @invoice = invoice.user, invoice

    subject 'Payment received'
    recipients "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def payment_failed(invoice)
    @user, @invoice = invoice.user, invoice

    subject 'Payment failed'
    recipients "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end
  
  def billing_job_error(user, error_message)
    @user, @error_message = user, error_message

    subject 'Billing job error'
    recipients ADMIN_MAILBOX
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def billing_job_missed_window(user)
    @user = user

    subject 'Billing job missed automatic billing window'
    recipients "TypeFront <#{MAIL_CONFIG[:webmaster_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

end
