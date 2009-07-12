class AddUserToFonts < ActiveRecord::Migration
  def self.up
    add_column :fonts, :user_id, :integer
  end

  def self.down
    remove_column :fonts, :user_id
  end
end
