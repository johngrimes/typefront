class AddFailedToFontFormats < ActiveRecord::Migration
  def self.up
    add_column :font_formats, :failed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :font_formats, :failed
  end
end
