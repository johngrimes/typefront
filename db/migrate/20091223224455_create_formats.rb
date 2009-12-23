class CreateFormats < ActiveRecord::Migration
  def self.up
    create_table :formats do |t|
      t.string :file_extension
      t.string :description
      t.string :distribution_file_name
      t.string :distribution_content_type
      t.integer :distribution_file_size
      t.datetime :distribution_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :formats
  end
end
