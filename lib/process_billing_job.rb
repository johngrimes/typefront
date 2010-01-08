# Delayed job for billing processing
class ProcessBillingJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    user.process_billing
  end
end
