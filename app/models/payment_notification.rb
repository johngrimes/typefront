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
      self.user.update_attribute(:active, true)
    when SUBSCRIPTION_MODIFIED
      subscription_level = CGI::parse(params[:custom])['subscription_level'].to_i
      self.user.update_attribute(:subscription_level, subscription_level)
    when SUBSCRIPTION_CANCELLED
      delete_account = CGI::parse(params[:custom])['delete_account']
      if delete_account == '1'
        self.user.destroy
      else
        self.user.update_attribute(:subscription_level, User::FREE)
      end
    end
  end
end
