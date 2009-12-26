class AddOriginalFormatToFont < ActiveRecord::Migration
  def self.up
    add_column :fonts, :original_format, :string
  end

  def self.down
    remove_column :fonts, :original_format
  end
end
