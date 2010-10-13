class AddGenerateJobsPendingToFont < ActiveRecord::Migration
  def self.up
    add_column :fonts, :generate_jobs_pending, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :fonts, :generate_jobs_pending
  end
end
