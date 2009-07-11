require 'paperclip'
require 'ttfunk'

class Font < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :domains
  has_attached_file :distribution,
    :path => ":rails_root/public/system/fonts/:attachment/:id/:style/:basename.:extension"

  TABLE_FIELDS =  [ 'copyright',
                    'font_family',
                    'font_subfamily',
                    'version',
                    'trademark',
                    'manufacturer',
                    'designer',
                    'description',
                    'vendor_url',
                    'designer_url',
                    'license',
                    'license_url',
                    'preferred_family',
                    'preferred_subfamily',
                    'compatible_full',
                    'sample_text'
                  ]

  validate :parse_format
  validates_attachment_presence :distribution

  protected

  def parse_format
    font = TTFunk::File.open(distribution.queued_for_write[:original].path)

    self.name = font.name.font_name.first.strip_extended

    TABLE_FIELDS.each do |field|
      if eval('font.name.' + field + '.first')
        eval('self.' + field + ' = font.name.' + field + '.first.strip_extended')
      end
    end
  rescue Exception => e
    errors.add(:distribution, "had a format that could not be read. (#{e.to_s})")
    return false
  end
end
