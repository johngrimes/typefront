class AddFontIdToDomain < ActiveRecord::Migration
  def self.up
    add_column :domains, :font_id, :integer
  end

  def self.down
    remove_column :domains, :font_id
  end
end
