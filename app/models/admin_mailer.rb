class AdminMailer < ActionMailer::Base
  ADMIN_MAILBOX = 'TypeFront <contact@smallspark.com.au>'
  
  def billing_job_error(user, error_message)
    @user, @error_message = user, error_message

    subject 'Billing job error'
    recipients ADMIN_MAILBOX
    from 'TypeFront <noreply@typefront.com>'
    sent_on Time.now
  end

  def billing_job_missed_window(user)
    @user = user

    subject 'Billing job missed automatic billing window'
    recipients ADMIN_MAILBOX
    from 'TypeFront <noreply@typefront.com>'
    sent_on Time.now
  end

end
