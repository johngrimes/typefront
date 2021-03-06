class CreatePaymentNotifications < ActiveRecord::Migration
  def self.up
    create_table :payment_notifications do |t|
      t.text :params
      t.integer :user_id
      t.string :status
      t.integer :transaction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_notifications
  end
end
