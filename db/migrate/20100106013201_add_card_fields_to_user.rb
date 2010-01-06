class AddCardFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :card_name, :string
    add_column :users, :card_type, :string
    add_column :users, :card_expiry, :date
  end

  def self.down
    remove_column :users, :card_expiry
    remove_column :users, :card_type
    remove_column :users, :card_name
  end
end
