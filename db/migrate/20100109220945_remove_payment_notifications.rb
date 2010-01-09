class RemovePaymentNotifications < ActiveRecord::Migration
  def self.up
    drop_table :payment_notifications
  end

  def self.down
    create_table :payment_notifications do |t|
      t.text :params
      t.integer :user_id
      t.string :status
      t.integer :transaction_id
      t.string :transaction_type
      t.integer :subscription_level
      t.boolean :delete_account

      t.timestamps
    end      
  end
end
