class RemoveLimitOnFontLicenseField < ActiveRecord::Migration
  def self.up
    change_column :fonts, :license, :text, :limit => false
  end

  def self.down
    change_column :fonts, :license, :string, :limit => 255
  end
end
