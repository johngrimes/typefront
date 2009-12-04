class RenameTypeInPaymentNotifications < ActiveRecord::Migration
  def self.up
    rename_column :payment_notifications, :type, :transaction_type
  end

  def self.down
    rename_column :payment_notifications, :transaction_type, :type
  end
end
