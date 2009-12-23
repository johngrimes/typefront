class RemoveDistributionFromFont < ActiveRecord::Migration
  def self.up
    remove_column :fonts, :distribution_file_name
    remove_column :fonts, :distribution_content_type
    remove_column :fonts, :distribution_file_size
    remove_column :fonts, :distribution_updated_at
  end

  def self.down
    add_column :fonts, :distribution_updated_at, :datetime
    add_column :fonts, :distribution_file_size, :integer
    add_column :fonts, :distribution_content_type, :string
    add_column :fonts, :distribution_file_name, :string
  end
end
