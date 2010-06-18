class UserMailer < ActionMailer::Base
  def activation(user)
    @user = user

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

  def password_reset(user)
    @user = user

    subject 'Change your password'
    recipients @user.email
    bcc "TypeFront <#{MAIL_CONFIG[:contact_email]}>"
    from "TypeFront <#{MAIL_CONFIG[:sender_email]}>"
    sent_on Time.now
  end
end
