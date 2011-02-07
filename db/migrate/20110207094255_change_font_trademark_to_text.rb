class ChangeFontTrademarkToText < ActiveRecord::Migration
  def self.up
    change_column :fonts, :trademark, :text, :limit => false
  end

  def self.down
    change_column :fonts, :trademark, :string
  end
end
