class FontFormat < ActiveRecord::Base
  belongs_to :font
  has_attached_file :distribution,
    :path => ":rails_root/public/system/formats/:attachment/:id/:style/:basename.:extension"

  named_scope :active, :conditions => { :active => true, :failed => false }
  named_scope :failed, :conditions => { :failed => true }

  attr_accessible :active

  validates_presence_of :file_extension, :description, :font
end
