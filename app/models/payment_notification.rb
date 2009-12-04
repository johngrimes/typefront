class PaymentNotification < ActiveRecord::Base
  belongs_to :user
  serialize :params
  after_create :trigger_actions

  NEW_SUBSCRIPTION_STARTED = 'subscr_signup'
  SUBSCRIPTION_MODIFIED = 'subscr_modify'
  SUBSCRIPTION_CANCELLED = 'subscr_cancel'

  protected

  def trigger_actions
    case transaction_type
    when NEW_SUBSCRIPTION_STARTED
      activate_user
    when SUBSCRIPTION_MODIFIED
      # Do something
    when SUBSCRIPTION_CANCELLED
      # Do something
    end
  end

  def activate_user
    self.user.update_attribute!(:active => true)
  end
end
