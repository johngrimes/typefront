class AddMaskedCardNumberToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :masked_card_number, :string
  end

  def self.down
    remove_column :users, :masked_card_number
  end
end
