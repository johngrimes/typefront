class ConvertAllLongFieldsToText < ActiveRecord::Migration
  def self.up
    change_column :fonts, :description, :text, :limit => false
    change_column :fonts, :vendor_url, :text, :limit => false
    change_column :fonts, :designer_url, :text, :limit => false
    change_column :fonts, :license_url, :text, :limit => false
    change_column :fonts, :sample_text, :text, :limit => false

    change_column :invoices, :description, :text, :limit => false

    change_column :invoices, :description, :text, :limit => false

    change_column :logged_requests, :referer, :text, :limit => false
    change_column :logged_requests, :origin, :text, :limit => false
    change_column :logged_requests, :user_agent, :text, :limit => false
  end

  def self.down
    change_column :fonts, :description, :string
    change_column :fonts, :vendor_url, :string
    change_column :fonts, :designer_url, :string
    change_column :fonts, :license_url, :string
    change_column :fonts, :sample_string, :string

    change_column :invoices, :description, :string

    change_column :invoices, :description, :string

    change_column :logged_requests, :referer, :string
    change_column :logged_requests, :origin, :string
    change_column :logged_requests, :user_agent, :string
  end
end
