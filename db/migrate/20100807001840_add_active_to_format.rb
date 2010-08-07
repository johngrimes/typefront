class AddActiveToFormat < ActiveRecord::Migration
  def self.up
    add_column :formats, :active, :boolean
  end

  def self.down
    remove_column :formats, :active
  end
end
