class AddTypeToPaymentNotification < ActiveRecord::Migration
  def self.up
    add_column :payment_notifications, :type, :string
  end

  def self.down
    remove_column :payment_notifications, :type
  end
end
