class RemoveLimitOnLoggedRequestReferer < ActiveRecord::Migration
  def self.up
    change_column :logged_requests, :referer, :string, :limit => false
  end

  def self.down
    change_column :logged_requests, :referer, :string, :limit => 255
  end
end
