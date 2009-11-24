class AddAdditionalSubscriptionFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_amount, :integer
    add_column :users, :fonts_allowed, :integer
  end

  def self.down
    add_column :users, :subscription_amount
    add_column :users, :fonts_allowed
  end
end
