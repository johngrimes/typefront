class AdminMailer < ActionMailer::Base
  
  def billing_job_error(user)
    @user, @error_message = user, error_message

    subject 'Billing job error'
    recipients 'TypeFront <noreply@typefront.com>'
    from 'TypeFront <contact@typefront.com>'
    sent_on Time.now
  end

end
