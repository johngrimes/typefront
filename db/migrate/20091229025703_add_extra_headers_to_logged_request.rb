class AddExtraHeadersToLoggedRequest < ActiveRecord::Migration
  def self.up
    add_column :logged_requests, :referer, :string
    add_column :logged_requests, :origin, :string
    add_column :logged_requests, :user_agent, :string
  end

  def self.down
    remove_column :logged_requests, :user_agent
    remove_column :logged_requests, :origin
    remove_column :logged_requests, :referer
  end
end
