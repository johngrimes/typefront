class ChangeFontCopyrightToText < ActiveRecord::Migration
  def self.up
    change_column :fonts, :copyright, :text, :limit => false
  end

  def self.down
    change_column :fonts, :copyright, :string
  end
end
