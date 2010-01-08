class UserMailer < ActionMailer::Base
  
  def activation(user)
    @user = user

    subject 'Activate your account'
    recipients @user.email
    from 'TypeFront <noreply@typefront.com>'
    sent_on Time.now
  end

end
