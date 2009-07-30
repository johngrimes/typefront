class AddAddressToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :address_1, :string
    add_column :users, :address_2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :postcode, :string
    add_column :users, :country, :string
  end

  def self.down
    remove_column :users, :country
    remove_column :users, :postcode
    remove_column :users, :state
    remove_column :users, :city
    remove_column :users, :address_2
    remove_column :users, :address_1
  end
end
