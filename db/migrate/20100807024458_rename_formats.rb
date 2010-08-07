class RenameFormats < ActiveRecord::Migration
  def self.up
    rename_table :formats, :font_formats
  end

  def self.down
    rename_table :font_formats, :formats
  end
end
