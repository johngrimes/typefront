class ChangeFontLicenceToText < ActiveRecord::Migration
  def self.up
    change_column :fonts, :license, :text
  end

  def self.down
    change_column :fonts, :license, :string
  end
end
