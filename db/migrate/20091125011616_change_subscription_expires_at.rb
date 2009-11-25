class ChangeSubscriptionExpiresAt < ActiveRecord::Migration
  def self.up
    rename_column :users, :subscription_expires_at, :subscription_renewal
    change_column :users, :subscription_renewal, :datetime
  end

  def self.down
    rename_column :users, :subscription_renewal, :subscription_expires_at
    change_column :users, :subscription_expires_at, :string
  end
end
