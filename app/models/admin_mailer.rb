class AdminMailer < ActionMailer::Base
  
  def billing_job_error(user, error_message)
    @user, @error_message = user, error_message

    subject 'Billing job error'
    recipients 'TypeFront <contact@typefront.com>'
    from 'TypeFront <noreply@typefront.com>'
    sent_on Time.now
  end

end
