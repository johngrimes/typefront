class AddTableFieldsToFonts < ActiveRecord::Migration
  def self.up
    add_column :fonts, :copyright, :string
    add_column :fonts, :font_family, :string
    add_column :fonts, :font_subfamily, :string
    add_column :fonts, :font_name, :string
    add_column :fonts, :version, :string
    add_column :fonts, :trademark, :string
    add_column :fonts, :manufacturer, :string
    add_column :fonts, :designer, :string
    add_column :fonts, :description, :string
    add_column :fonts, :vendor_url, :string
    add_column :fonts, :designer_url, :string
    add_column :fonts, :license, :string
    add_column :fonts, :license_url, :string
    add_column :fonts, :preferred_family, :string
    add_column :fonts, :preferred_subfamily, :string
    add_column :fonts, :compatible_full, :string
    add_column :fonts, :sample_text, :string
  end

  def self.down
    remove_column :fonts, :sample_text
    remove_column :fonts, :compatible_full
    remove_column :fonts, :preferred_subfamily
    remove_column :fonts, :preferred_family
    remove_column :fonts, :license_url
    remove_column :fonts, :license
    remove_column :fonts, :designer_url
    remove_column :fonts, :vendor_url
    remove_column :fonts, :description
    remove_column :fonts, :designer
    remove_column :fonts, :manufacturer
    remove_column :fonts, :trademark
    remove_column :fonts, :version
    remove_column :fonts, :font_name
    remove_column :fonts, :font_subfamily
    remove_column :fonts, :font_family
    remove_column :fonts, :copyright
  end
end
