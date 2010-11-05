require 'paperclip'
require 'fontadapter'

class Font < ActiveRecord::Base
  belongs_to :user
  belongs_to :font
  has_many :font_formats, :dependent => :destroy
  has_many :domains, :dependent => :destroy
  has_attached_file :original

  named_scope :ready, :conditions => { :generate_jobs_pending => 0 }

  AVAILABLE_FORMATS = [:ttf, :otf, :woff, :eot, :svg]
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

  attr_accessible :original, :verification

  attr_accessor :verification

  validates_attachment_presence :original, :message => 'You need to choose a file before clicking Upload.'
  validates_acceptance_of :verification, 
    :message => 'It is a requirement that you accept this condition before uploading your font file.', 
    :allow_nil => false, :on => :create
  validate :original_file_valid?

  after_create :generate_all_formats

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
    if options[:ignore_inactive] && format = font_formats.present.find_by_file_extension(format.to_s)
      return format
    elsif format = font_formats.present.active.find_by_file_extension(format.to_s)
      return format
    elsif options[:raise_error]
      raise ActiveRecord::RecordNotFound, 'Could not find the specified format for that font.'
    else
      return nil
    end
  end

  def log_request(action, options = {})
    typefront_request = !options[:referer].blank? && 
      (options[:referer].index($HOST) != nil || options[:referer].index($HOST_SSL) != nil)
    font_download = AVAILABLE_FORMATS.include?(options[:format])

    if font_download && !typefront_request
      logged_request = LoggedRequest.new
      logged_request.font_id = self.id
      logged_request.user_id = self.user_id
      logged_request.action = action
      logged_request.format = options[:format].to_s
      logged_request.remote_ip = options[:remote_ip]
      logged_request.referer = options[:referer]
      logged_request.origin = options[:origin]
      logged_request.user_agent = options[:user_agent]
      logged_request.response_time = options[:response_time]
      logged_request.raw_request = options[:raw_request]
      logged_request.rejected = options[:rejected]
      logged_request.save
    end
  end

  def notices
    notices = []
    notices << "None of your font formats are currently active. You can activate formats on the 'Font information' tab." if font_formats.present.active.empty?
    notices << "You have not added any allowed domains for this font. You can do this on the 'Allowed domains' tab." if domains.empty?
    notices << 'One or more of your allowed domains is missing a protocol prefix (http:// or https://).' unless domains.select { |x| !(x.domain.index('http://') || x.domain.index('https://')) }.empty?
    notices << 'One or more of your allowed domains has a trailing slash (/), which could cause problems in Firefox.' unless domains.select { |x| x.domain =~ /\/$/ }.empty?
    notices << "One or more of your font formats failed during processing - please let us know via the <a href=\"#{APP_CONFIG[:support_url]}\">support page</a>." unless font_formats.failed.empty?
    return notices
  end

  def generate_all_formats
    formats = { :ttf => 'TrueType', :otf => 'OpenType', :woff => 'Web Open Font Format', :eot => 'Extended OpenType', :svg => 'Scalable Vector Graphics' }
    formats.each do |format, description|
      Resque.enqueue(GenerateFormatJob, :font_id => id, :format => format.to_s, :description => description)
    end
    update_attribute(:generate_jobs_pending, self.generate_jobs_pending + formats.size)
  end

  def generate_format(format, description)
    if existing_format = font_formats.find_by_file_extension(format.to_s)
      existing_active = existing_format.active
      existing_format.destroy
    end

    temp_path = temp_location("typefront_#{ActiveSupport::SecureRandom.hex(5)}.#{format}")
    
    adapter = FontAdapter.new(self.original.path, $FAILED_FONT_DIR)
    new_format = FontFormat.new
    new_format.font = self
    new_format.file_extension = format
    new_format.description = description
    new_format.active = existing_active || false
    new_format.output = adapter.send("to_#{format}", temp_path)
    new_format.distribution = ActionController::TestUploadedFile.new(temp_path, "font/#{format}")
    new_format.failed = false
    new_format.save!
    FileUtils.rm_f(temp_path)

  rescue FontConversionException => e
    new_format.output = e.message
    new_format.failed = true
    new_format.save!
    FileUtils.rm_f(temp_path)
    raise
  end

  protected

  def original_file_valid?
    if original.queued_for_write[:original]
      original_path = original.queued_for_write[:original].path

      @adapter = FontAdapter.new(original_path, $FAILED_FONT_DIR)
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
    errors.add(:original, 'had a format that we did not recognise. Please upload a valid font file in TrueType, OpenType or WOFF format. If you think your font file is in fact valid, please let us know.')
    return false
  end

  def temp_location(path)
    temp_dir = Dir::tmpdir || '/tmp'
    File.expand_path(temp_dir + '/' + File.basename(path))
  end
end
