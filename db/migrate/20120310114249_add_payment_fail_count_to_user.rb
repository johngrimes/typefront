class AddPaymentFailCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :payment_fail_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :payment_fail_count
  end
end
