class AddFormatTimeToLoggedRequest < ActiveRecord::Migration
  def self.up
    add_column :logged_requests, :format, :string
    add_column :logged_requests, :response_time, :decimal, :precision => 10, :scale => 3
  end

  def self.down
    remove_column :logged_requests, :response_time
    remove_column :logged_requests, :format
  end
end
