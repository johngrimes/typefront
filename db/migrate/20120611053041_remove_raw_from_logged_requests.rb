class RemoveRawFromLoggedRequests < ActiveRecord::Migration
  def self.up
    remove_column :logged_requests, :raw_request
  end

  def self.down
    add_column :logged_requests, :raw_request, :text
  end
end
