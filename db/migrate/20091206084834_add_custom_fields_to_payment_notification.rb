class AddCustomFieldsToPaymentNotification < ActiveRecord::Migration
  def self.up
    add_column :payment_notifications, :subscription_level, :integer
    add_column :payment_notifications, :delete_account, :boolean
  end

  def self.down
    remove_column :payment_notifications, :delete_account
    remove_column :payment_notifications, :subscription_level
  end
end
