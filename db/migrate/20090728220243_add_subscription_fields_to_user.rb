class AddSubscriptionFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_level, :string
    add_column :users, :request_credits, :integer
    add_column :users, :subscription_expires_at, :string
  end

  def self.down
    remove_column :users, :subscription_expires_at
    remove_column :users, :request_credits
    remove_column :users, :subscription_level
  end
end
