class AddOriginalToFont < ActiveRecord::Migration
  def self.up
    add_column :fonts, :original_file_name, :string
    add_column :fonts, :original_content_type, :string
    add_column :fonts, :original_file_size, :integer
    add_column :fonts, :original_updated_at, :datetime
  end

  def self.down
    remove_column :fonts, :original_updated_at
    remove_column :fonts, :original_file_size
    remove_column :fonts, :original_content_type
    remove_column :fonts, :original_file_name
  end
end
