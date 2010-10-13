class BillingJob
  @queue = :billing

  def self.perform(options = {})
    options.symbolize_keys!
    user = User.find(options[:user_id])
    user.process_billing
  end

  def self.on_failure_email_admin(exception, *args)
    options = args.last.symbolize_keys!
    user = User.find(options[:user_id])
    AdminMailer.deliver_billing_job_error(user, exception.message)
  end
end
