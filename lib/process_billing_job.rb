class ProcessBillingJob < Struct.new(:user)
  def perform
    user.process_billing
  end
end
