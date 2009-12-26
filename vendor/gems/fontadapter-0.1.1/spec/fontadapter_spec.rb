require 'spec_helper'

TTF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/lucidagrande.ttf')
OTF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/droid.ttf')
WOFF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/gentium.woff')
BOGUS_PATH = File.expand_path(File.dirname(__FILE__) + '/files/symbol.pfb')
TEMP_WOFF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/temp.woff')
TEMP_OTF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/temp.otf')
TEMP_EOT_PATH = File.expand_path(File.dirname(__FILE__) + '/files/temp.eot')
TRUETYPE_FONTS_DIR = File.expand_path(File.dirname(__FILE__) + '/files/truetype')
OPENTYPE_FONTS_DIR = File.expand_path(File.dirname(__FILE__) + '/files/opentype')

describe 'FontAdapter' do
  
  it 'should load a valid TrueType font file' do
    fontadapter = FontAdapter.new(TTF_PATH)
    fontadapter.format.should == FontAdapter::TTF
  end

  it 'should load a valid OpenType font file' do
    fontadapter = FontAdapter.new(OTF_PATH)
    fontadapter.format.should == FontAdapter::OTF
  end

  it 'should load a valid WOFF file' do
    fontadapter = FontAdapter.new(WOFF_PATH)
    fontadapter.format.should == FontAdapter::WOFF
  end

  it 'should raise an exception if loading an unsupported font file format' do
    lambda {
      fontadapter = FontAdapter.new(BOGUS_PATH)
    }.should raise_error(Exception)
  end

  it 'should convert a TrueType font file to a WOFF and then back again' do
    ttf_adapter = FontAdapter.new(TTF_PATH)
    ttf_adapter.to_woff(TEMP_WOFF_PATH)

    woff_adapter = FontAdapter.new(TEMP_WOFF_PATH)
    woff_adapter.format.should == FontAdapter::WOFF
    otf = woff_adapter.to_otf(TEMP_OTF_PATH)

    otf_adapter = FontAdapter.new(TEMP_OTF_PATH)
    otf_adapter.format.should == FontAdapter::TTF

    FileUtils.rm TEMP_OTF_PATH
  end

  it 'should convert a WOFF to an OpenType font file and then back again' do
    woff_adapter = FontAdapter.new(WOFF_PATH)
    woff_adapter.to_otf(TEMP_OTF_PATH)

    otf_adapter = FontAdapter.new(TEMP_OTF_PATH)
    otf_adapter.to_woff(TEMP_WOFF_PATH)

    woff_adapter = FontAdapter.new(TEMP_WOFF_PATH)
    woff_adapter.format.should == FontAdapter::WOFF

    FileUtils.rm [TEMP_WOFF_PATH, TEMP_OTF_PATH]
  end

  it 'should convert a WOFF to an EOT' do
    woff_adapter = FontAdapter.new(WOFF_PATH)
    woff_adapter.to_eot(TEMP_EOT_PATH)
    File.exists?(TEMP_EOT_PATH).should == true

    FileUtils.rm TEMP_EOT_PATH
  end
  
  it 'should convert a OpenType font file to an EOT' do
    otf_adapter = FontAdapter.new(OTF_PATH)
    otf_adapter.to_eot(TEMP_EOT_PATH)
    File.exists?(TEMP_EOT_PATH).should == true

    FileUtils.rm TEMP_EOT_PATH
  end

  it 'should convert a TrueType font file to an EOT' do
    ttf_adapter = FontAdapter.new(TTF_PATH)
    ttf_adapter.to_eot(TEMP_EOT_PATH)
    File.exists?(TEMP_EOT_PATH).should == true

    FileUtils.rm TEMP_EOT_PATH
  end

  it 'should load a variety of different TrueType font files' do
    font_paths = Dir.entries(TRUETYPE_FONTS_DIR)
    font_paths.delete('..')
    font_paths.delete('.')
    font_paths.map! { |x| File.expand_path(TRUETYPE_FONTS_DIR + '/' + x) }
    font_paths.each do |font_path|
      if font_path != '.' && font_path != '..'
#         puts 'Loading ' + File.basename(font_path)
        fontadapter = FontAdapter.new(font_path)
        fontadapter.format.should == FontAdapter::TTF
      end
    end
  end

  it 'should load a variety of different OpenType font files' do
    font_paths = Dir.entries(OPENTYPE_FONTS_DIR)
    font_paths.delete('..')
    font_paths.delete('.')
    font_paths.map! { |x| File.expand_path(OPENTYPE_FONTS_DIR + '/' + x) }
    font_paths.each do |font_path|
      if font_path != '.' && font_path != '..'
#         puts 'Loading ' + File.basename(font_path)
        fontadapter = FontAdapter.new(font_path)
        fontadapter.format.should == FontAdapter::OTF
      end
    end
  end
end
