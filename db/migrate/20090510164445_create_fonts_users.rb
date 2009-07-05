class CreateFontsUsers < ActiveRecord::Migration
  def self.up
    create_table :fonts_users, :id => false do |t|
      t.integer :user_id
      t.integer :font_id
      t.timestamps
    end
  end

  def self.down
    drop_table :fonts_users
  end
end
