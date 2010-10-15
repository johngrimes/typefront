class AddOutputToFontFormats < ActiveRecord::Migration
  def self.up
    add_column :font_formats, :output, :text
  end

  def self.down
    remove_column :font_formats, :output
  end
end
