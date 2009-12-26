class Format < ActiveRecord::Base
  belongs_to :font
  has_attached_file :distribution,
    :path => ":rails_root/public/system/formats/:attachment/:id/:style/:basename.:extension"

  validates_attachment_presence :distribution
end
