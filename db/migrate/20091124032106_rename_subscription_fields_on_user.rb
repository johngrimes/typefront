class RenameSubscriptionFieldsOnUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :subscription_level, :subscription_name
    rename_column :users, :request_credits, :requests_allowed
  end

  def self.down
    rename_column :users, :subscription_name, :subscription_level
    rename_column :users, :requests_allowed, :request_credits
  end
end
