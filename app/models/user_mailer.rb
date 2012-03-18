class UserMailer < ActionMailer::Base
  def activation(user_id)
    @user = User.find(user_id)

    subject 'Activate your account'
    recipients @user.email
    bcc "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def receipt(invoice)
    @user, @invoice = invoice.user, invoice

    subject 'Receipt for TypeFront subscription'
    recipients @user.email
    bcc "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def password_reset(user_id)
    @user = User.find(user_id)

    subject 'Change your password'
    recipients @user.email
    bcc "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def payment_failed(invoice)
    @invoice = invoice
    @user = @invoice.user
    @fail_count = @user.payment_fail_count
    raise Exception, "Invalid payment fail count of #{@fail_count} encountered in UserMailer#payment_failed" if @fail_count == 0

    subject 'Payment failed'
    recipients @user.email
    bcc "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end

  def account_downgraded(invoice)
    @invoice = invoice
    @user = @invoice.user

    subject 'Account downgraded'
    recipients @user.email
    bcc "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end
end
