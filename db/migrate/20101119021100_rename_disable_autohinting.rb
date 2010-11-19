class RenameDisableAutohinting < ActiveRecord::Migration
  def self.up
    rename_column :fonts, :disable_autohinting, :autohinting_enabled
  end

  def self.down
    rename_column :fonts, :autohinting_enabled, :disable_autohinting
  end
end
