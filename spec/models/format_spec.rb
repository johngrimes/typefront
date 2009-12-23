require 'spec_helper'

describe Format do
  before(:each) do
    @valid_attributes = {
      :file_extension => "value for file_extension",
      :description => "value for description",
      :distribution_file_name => "value for distribution_file_name",
      :distribution_content_type => "value for distribution_content_type",
      :distribution_file_size => 1,
      :distribution_updated_at => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Format.create!(@valid_attributes)
  end
end
