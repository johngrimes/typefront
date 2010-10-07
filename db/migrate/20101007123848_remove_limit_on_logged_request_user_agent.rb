class RemoveLimitOnLoggedRequestUserAgent < ActiveRecord::Migration
  def self.up
    change_column :logged_requests, :user_agent, :string, :limit => false
  end

  def self.down
    change_column :logged_requests, :user_agent, :string, :limit => 255
  end
end
