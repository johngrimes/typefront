require 'font_file'
require 'font_conversions'

class FontAdapter
  TTF = 'ttf'
  OTF = 'otf'
  WOFF = 'woff'

  attr_reader :file, :font_file, :format, :outline_format

  def initialize(filename, failed_font_dir = '/tmp/failed_fonts')
    @file = File.new(filename)
    @failed_font_dir = failed_font_dir
    determine_format
  end

  def to_ttf(output_path)
    temp_sfnt_path = File.basename_without_ext(output_path) + '_temp.sfnt'

    case @format
    when OTF, TTF
      FontConversions.sfnt_to_ttf(@file.path, output_path)
    when WOFF
      FontConversions.woff_to_sfnt(@file.path, temp_sfnt_path)
      FontConversions.sfnt_to_ttf(temp_sfnt_path, output_path)
      FileUtils.rm temp_sfnt_path
    end
  end

  def to_otf(output_path)
    temp_sfnt_path = File.basename_without_ext(output_path) + '_temp.sfnt'

    case @format
    when OTF, TTF
      FontConversions.sfnt_to_otf(@file.path, output_path)
    when WOFF
      FontConversions.woff_to_sfnt(@file.path, temp_sfnt_path)
      FontConversions.sfnt_to_otf(temp_sfnt_path, output_path)
      FileUtils.rm temp_sfnt_path
    end
  end

  def to_woff(output_path)
    temp_ttf_path = File.basename_without_ext(output_path) + '_temp.ttf'
    temp_sfnt_path = File.basename_without_ext(output_path) + '_temp.sfnt'

    case @format
    when OTF, TTF
      FontConversions.sfnt_to_ttf(@file.path, temp_ttf_path)
      FontConversions.sfnt_to_woff(temp_ttf_path, output_path)
      FileUtils.rm temp_ttf_path
    when WOFF
      FontConversions.woff_to_sfnt(@file.path, temp_sfnt_path)
      FontConversions.sfnt_to_ttf(temp_sfnt_path, temp_ttf_path)
      FontConversions.sfnt_to_woff(temp_ttf_path, output_path)
      FileUtils.rm [temp_sfnt_path, temp_ttf_path]
    end
  end

  def to_eot(output_path)
    temp_ttf_path = File.basename_without_ext(output_path) + '_temp.ttf'
    temp_sfnt_path = File.basename_without_ext(output_path) + '_temp.sfnt'

    case @format
    when OTF, TTF
      FontConversions.sfnt_to_ttf(@file.path, temp_ttf_path)
      FontConversions.ttf_to_eot(temp_ttf_path, output_path)
      FileUtils.rm temp_ttf_path
    when WOFF
      FontConversions.woff_to_sfnt(@file.path, temp_sfnt_path)
      FontConversions.sfnt_to_ttf(temp_sfnt_path, temp_ttf_path)
      FontConversions.ttf_to_eot(temp_ttf_path, output_path)
      FileUtils.rm [temp_sfnt_path, temp_ttf_path]
    end
  end

  def to_svg(output_path)
    temp_ttf_path = File.basename_without_ext(output_path) + '_temp.ttf'
    temp_sfnt_path = File.basename_without_ext(output_path) + '_temp.sfnt'

    case @format
    when OTF, TTF
      FontConversions.sfnt_to_ttf(@file.path, temp_ttf_path)
      FontConversions.ttf_to_svg(temp_ttf_path, output_path)
      FileUtils.rm temp_ttf_path
    when WOFF
      FontConversions.woff_to_sfnt(@file.path, temp_sfnt_path)
      FontConversions.sfnt_to_ttf(temp_sfnt_path, temp_ttf_path)
      FontConversions.ttf_to_svg(temp_ttf_path, output_path)
      FileUtils.rm [temp_sfnt_path, temp_ttf_path]
    end
  end

  protected

  def determine_format
    begin
      @font_file = BinaryFile::TruetypeFontFile.open(@file.path)
      @format = TTF
      @outline_format = @font_file.offset.scaler_type.value.to_s(16)
#       puts @format
#       puts 'SFNT version: ' + @font_file.offset.scaler_type.value.to_s(16)
    rescue BinaryFile::FileValidationError => e

      begin
        @font_file = BinaryFile::OpentypeFontFile.open(@file.path)
        @format = OTF
        @outline_format = @font_file.offset.scaler_type.value.to_s(16)
#         puts @format
#         puts 'SFNT version: ' + @font_file.offset.scaler_type.value.to_s(16)
#         puts 'OpenType tables: ' + (@font_file.tables.collect {|x| x.name[0..3].downcase} & OTF_TABLES.collect {|x| x.downcase}).inspect
      rescue BinaryFile::FileValidationError => e

        begin
          @font_file = BinaryFile::WebOpenFontFile.open(@file.path)
          @format = WOFF
          @outline_format = @font_file.header.flavor.value.to_s(16)
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
