class AddDisableAutohintingToFont < ActiveRecord::Migration
  def self.up
    add_column :fonts, :disable_autohinting, :boolean, :default => '0'
  end

  def self.down
    remove_column :fonts, :disable_autohinting
  end
end
