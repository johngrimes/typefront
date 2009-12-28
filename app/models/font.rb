require 'paperclip'
require 'fontadapter'

class Font < ActiveRecord::Base
  belongs_to :user
  has_many :formats, :dependent => :destroy
  has_many :domains, :dependent => :destroy
  has_attached_file :original

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

    INFO_FIELDS.each do |field|
      info_value = eval("@adapter.font_file.#{field}")
      if info_value
        info_value = info_value.gsub(/[\x00-\x19\x80-\xff]/n, "")
      end
      eval("self.#{field} = info_value")
    end

  rescue UnrecognisedFileFormatError => e
    errors.add(:distribution, "had a format that was not valid. Please upload a valid font file in TrueType, OpenType or WOFF format. If you think this message is in error, please let us know. #{e}")
    return false
  end

  def save_attached_files_with_post_process
    save_attached_files_without_post_process
    generate_format('otf', 'OpenType')
    generate_format('woff', 'Web Open Font Format')
    generate_format('eot', 'Extended OpenType')
  end
  alias_method_chain :save_attached_files, :post_process

  def generate_format(format, description)
    if existing_format = formats.find_by_file_extension(format.to_s)
      existing_format.destroy
    end

    temp_path = temp_location("typefront_#{ActiveSupport::SecureRandom.hex(5)}.#{format}")
    
    adapter = FontAdapter.new(self.original.path)
    eval("adapter.to_#{format}(temp_path)")
    
    new_format = Format.new
    new_format.font = self
    new_format.file_extension = format
    new_format.description = description
    new_format.distribution = ActionController::TestUploadedFile.new(temp_path, "font/#{format}")
    new_format.save!

    FileUtils.rm(temp_path)
  end

  def temp_location(path)
    temp_dir = Dir::tmpdir || '/tmp'
    File.expand_path(temp_dir + '/' + File.basename(path))
  end
end
