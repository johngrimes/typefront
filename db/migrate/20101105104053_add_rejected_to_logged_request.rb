class AddRejectedToLoggedRequest < ActiveRecord::Migration
  def self.up
    add_column :logged_requests, :rejected, :boolean, :default => 'f'
  end

  def self.down
    remove_column :logged_requests, :rejected
  end
end
