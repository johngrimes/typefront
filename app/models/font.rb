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

  attr_accessible :original

  validates_attachment_presence :original
  validate :original_file_valid?

  def full_name
    if self.font_family.blank? && self.font_subfamily.blank?
      self.name
    elsif self.font_subfamily.blank?
      self.font_family
    elsif !self.font_family.blank? && !self.font_subfamily.blank?
      "#{self.font_family} #{self.font_subfamily}"
    end
  end

  def format(format, options = {})
    if format = formats.find_by_file_extension(format.to_s)
      format
    elsif options[:raise_error]
      raise ActiveRecord::RecordNotFound, 'Could not find the specified format for that font.'
    else
      return nil
    end
  end

  def log_request(action, options = {})
    logged_request = LoggedRequest.new
    logged_request.font_id = self.id
    logged_request.user_id = self.user_id
    logged_request.action = action
    logged_request.remote_ip = options[:remote_ip]
    logged_request.referer = options[:referer]
    logged_request.origin = options[:origin]
    logged_request.user_agent = options[:user_agent]
    logged_request.save
  end

  protected

  def original_file_valid?
    if original.queued_for_write[:original]
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

      end
    return true

  rescue UnrecognisedFileFormatError => e
    errors.add(:original, "had a format that was is not supported. Please upload a valid font file in TrueType, OpenType or WOFF format. If you think your font file is valid, please let us know.")
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
