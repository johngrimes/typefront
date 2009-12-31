class AddIndexToFormat < ActiveRecord::Migration
  def self.up
    add_index :formats, [:font_id, :file_extension], :unique => true
  end

  def self.down
    remove_index :formats, [:font_id, :file_extension]
  end
end
