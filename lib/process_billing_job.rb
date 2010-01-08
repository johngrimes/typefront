# Delayed job for billing processing
class ProcessBillingJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    user.process_billing
  rescue Exception => e
    AdminMailer.deliver_billing_job_error(user, e.message)
  end
end
