class AddRawRequestToLoggedRequest < ActiveRecord::Migration
  def self.up
    add_column :logged_requests, :raw_request, :text
  end

  def self.down
    remove_column :logged_requests, :raw_request
  end
end
