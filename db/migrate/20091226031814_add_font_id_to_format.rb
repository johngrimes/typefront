class AddFontIdToFormat < ActiveRecord::Migration
  def self.up
    add_column :formats, :font_id, :integer
  end

  def self.down
    remove_column :formats, :font_id
  end
end
