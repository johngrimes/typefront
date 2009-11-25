class AddSubscriptionLevelToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_level, :integer
  end

  def self.down
    remove_column :users, :subscription_level
  end
end
