require 'paperclip'
require 'fontadapter'

class Font < ActiveRecord::Base
  belongs_to :user
  has_many :formats
  has_many :domains
  has_attached_file :original,
    :path => ":rails_root/public/system/fonts/:attachment/:id/:style/:basename.:extension"

  INFO_FIELDS =  [ 'font_family',
                   'font_subfamily',
                   'copyright',
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

  validates_attachment_presence :original
  validate :original_file_valid?
  after_create :generate_formats

  def full_name
    if self.font_family.blank? && self.font_subfamily.blank?
      self.name
    elsif self.font_subfamily.blank?
      self.font_family
    elsif !self.font_family.blank? && !self.font_subfamily.blank?
      "#{self.font_family} #{self.font_subfamily}"
    else
      name
    end
  end

  def format(format)
    if format = formats.find_by_file_extension(format.to_s)
      format
    else
      raise ActiveRecord::RecordNotFound, 'Could not find the specified format for that font.'
    end
  end

  protected

  def original_file_valid?
    original_path = original.queued_for_write[:original].path

    @adapter = FontAdapter.new(original_path)
    self.original_format = @adapter.format

  rescue Exception => e
    errors.add(:distribution, "had a format that was not valid. Please upload a valid font file in TrueType, OpenType or WOFF format. If you think this message is in error, please let us know.")
    return false
  end

  def generate_formats
    generate_format('otf', 'OpenType')
    generate_format('woff', 'Web Open Font Format')
    generate_format('eot', 'Extended OpenType')
  end

  def generate_format(format, description)
    temp_path = temp_location("typefront_#{Time.now.to_i}.#{format}")
    
    adapter = FontAdapter.new(self.original.path)
    eval("adapter.to_#{format}(temp_path)")
    
    new_format = Format.new
    new_format.file_extension = format
    new_format.description = description
    new_format.distribution = uploaded_file(temp_path)
    new_format.save!

    FileUtils.rm(temp_path)
  end

  def temp_location(path)
    temp_dir = Dir::tmpdir || '/tmp'
    File.expand_path(temp_dir + '/' + File.basename(path))
  end
end
