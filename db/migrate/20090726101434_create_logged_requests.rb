class CreateLoggedRequests < ActiveRecord::Migration
  def self.up
    create_table :logged_requests do |t|
      t.integer :user_id
      t.integer :font_id
      t.string :action
      t.string :remote_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :logged_requests
  end
end
