require 'base64'

class FontFormat < ActiveRecord::Base
  belongs_to :font
  has_attached_file :distribution,
    :path => ":rails_root/public/system/formats/:attachment/:id/:style/:basename.:extension"

  named_scope :present, :conditions => { :failed => false }
  named_scope :active, :conditions => { :active => true }
  named_scope :failed, :conditions => { :failed => true }

  attr_accessible :active

  validates_presence_of :file_extension, :description, :font

  def output=(output_text)
    self.write_attribute(:output, Base64.encode64(output_text)) unless output_text.blank?
  end

  def output
    Base64.decode64(self.read_attribute(:output)) unless self.read_attribute(:output).blank?
  end
end
