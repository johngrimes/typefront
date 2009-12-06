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
      if subscription_level.blank?
        self.user.update_attribute(:active, true)
      else
        self.user.update_attributes(:active => true,
                                    :subscription_level => subscription_level)
      end
    when SUBSCRIPTION_MODIFIED
      self.user.update_attribute(:subscription_level, subscription_level)
    when SUBSCRIPTION_CANCELLED
      if delete_account
        self.user.destroy
      else
        self.user.update_attribute(:subscription_level, User::FREE)
      end
    end
  end
end
