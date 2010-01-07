class AddGatewayCustomerIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :gateway_customer_id, :string
  end

  def self.down
    remove_column :users, :gateway_customer_id
  end
end
