class FontFormat < ActiveRecord::Base
  belongs_to :font
  has_attached_file :distribution,
    :path => ":rails_root/public/system/formats/:attachment/:id/:style/:basename.:extension"

  attr_accessible :active

  validates_presence_of :file_extension, :description, :font
  validates_attachment_presence :distribution
end
