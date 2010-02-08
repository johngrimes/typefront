require 'font_file'
require 'font_conversions'

class FontAdapter
  TTF = 'ttf'
  OTF = 'otf'
  WOFF = 'woff'

  attr_reader :file, :font_file, :format
  attr_accessor :failed_font_dir

  def initialize(filename)
    @file = File.new(filename)
    @failed_font_dir = '/tmp/failed_fonts'
    determine_format
  end

  def to_otf(output_path)
    case @format
    when OTF, TTF
      FileUtils.copy(@file.path, output_path)
    when WOFF
      FontConversions.woff_to_otf(@file.path, output_path)
    end
  end

  def to_woff(output_path)
    case @format
    when WOFF
      FileUtils.copy(@file.path, output_path)
    when OTF, TTF
      FontConversions.sfnt_to_woff(@file.path, output_path)
    end
  end

  def to_eot(output_path)
    temp_otf_path = output_path + '.temp.otf'
    temp_ttf_path = output_path + '.temp.ttf'

    case @format
    when WOFF
      FontConversions.woff_to_otf(@file.path, temp_otf_path)
      FontConversions.otf_to_ttf(temp_otf_path, temp_ttf_path)
      FontConversions.ttf_to_eot(temp_ttf_path, output_path)

      FileUtils.rm [temp_otf_path, temp_ttf_path]
    when OTF
      FontConversions.otf_to_ttf(@file.path, temp_ttf_path)
      FontConversions.ttf_to_eot(temp_ttf_path, output_path)

      FileUtils.rm temp_ttf_path
    when TTF
      FontConversions.ttf_to_eot(@file.path, output_path)
    end
  end

  protected

  def determine_format
    begin
      @font_file = BinaryFile::TruetypeFontFile.open(@file.path)
      @format = TTF
#       puts @format
#       puts 'SFNT version: ' + @font_file.offset.scaler_type.value.to_s(16)
    rescue BinaryFile::FileValidationError => e

      begin
        @font_file = BinaryFile::OpentypeFontFile.open(@file.path)
        @format = OTF
#         puts @format
#         puts 'SFNT version: ' + @font_file.offset.scaler_type.value.to_s(16)
      rescue BinaryFile::FileValidationError => e

        begin
          @font_file = BinaryFile::WebOpenFontFile.open(@file.path)
          @format = WOFF
#           puts @format
#           puts 'SFNT version: ' + @font_file.header.flavor.value.to_s(16)
        rescue BinaryFile::FileValidationError => e
          raise UnrecognisedFileFormatError, 'Unrecognised file format. Font must be in valid TrueType, OpenType or WOFF format.'
        end
     
      end

    end      

  rescue Exception
    FileUtils.copy(@file.path, File.expand_path(@failed_font_dir + '/' + File.basename(@file.path)))
    raise
  end
end

class UnrecognisedFileFormatError < Exception
end
