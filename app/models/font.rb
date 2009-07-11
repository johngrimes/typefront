require 'paperclip'
require 'ttfunk'

class Font < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :domains
  has_attached_file :distribution,
    :path => ":rails_root/public/system/fonts/:attachment/:id/:style/:basename.:extension"

  validate :parse_format
  validates_attachment_presence :distribution

  protected

  def parse_format
    truetype = TTFunk::File.open(distribution.queued_for_write[:original].path)
    self.name = truetype.name.font_name.first.strip_extended
  rescue Exception => e
    errors.add(:distribution, "had a format that could not be read. (#{e.to_s})")
    return false
  end
end
