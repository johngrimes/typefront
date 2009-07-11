class RemoveFormatFromFonts < ActiveRecord::Migration
  def self.up
    remove_column :fonts, :format
  end

  def self.down
    add_column :fonts, :format, :string
  end
end
