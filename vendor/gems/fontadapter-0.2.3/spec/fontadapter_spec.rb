require 'spec_helper'

TTF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/lucidagrande.ttf')
OTF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/droid.TTF')
WOFF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/gentium.woff')
BOGUS_PATH = File.expand_path(File.dirname(__FILE__) + '/files/symbol.pfb')
TEMP_WOFF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/temp.woff')
TEMP_OTF_PATH = File.expand_path(File.dirname(__FILE__) + '/files/temp.otf')
TEMP_EOT_PATH = File.expand_path(File.dirname(__FILE__) + '/files/temp.eot')
TRUETYPE_FONTS_DIR = File.expand_path(File.dirname(__FILE__) + '/files/truetype')
OPENTYPE_FONTS_DIR = File.expand_path(File.dirname(__FILE__) + '/files/opentype')
WOFF_FONTS_DIR = File.expand_path(File.dirname(__FILE__) + '/files/woff')

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
    }.should raise_error(UnrecognisedFileFormatError)
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

  it 'should load a variety of different WOFF files' do
    font_paths = Dir.entries(WOFF_FONTS_DIR)
    font_paths.delete('..')
    font_paths.delete('.')
    font_paths.map! { |x| File.expand_path(WOFF_FONTS_DIR + '/' + x) }
    font_paths.each do |font_path|
      if font_path != '.' && font_path != '..'
#         puts 'Loading ' + File.basename(font_path)
        fontadapter = FontAdapter.new(font_path)
        fontadapter.format.should == FontAdapter::WOFF
      end
    end
  end

  it 'should extract correct name fields for Lucida Grande' do
    fontadapter = FontAdapter.new(TTF_PATH)
    fontadapter.font_file.copyright.should == 'Copyright 1997 Bigelow & Holmes Inc. U.S. Pat. Des. 289,420. All rights reserved.'
    fontadapter.font_file.font_family.should == 'Lucida Grande'
    fontadapter.font_file.font_subfamily.should == 'Regular'
    fontadapter.font_file.unique_font_id.should == 'Lucida Grande; 16 Nov 1999'
    fontadapter.font_file.full_name.should == 'Lucida Grande'
    fontadapter.font_file.version.should == '0.24.1'
    fontadapter.font_file.postscript_name.should == 'LucidaGrande'
    fontadapter.font_file.trademark.should == 'Lucida is a registered trademark of Bigelow & Holmes Inc.'
    fontadapter.font_file.manufacturer.should == nil
    fontadapter.font_file.designer.should == nil
    fontadapter.font_file.description.should == nil
    fontadapter.font_file.vendor_url.should == nil
    fontadapter.font_file.designer_url.should == nil
    fontadapter.font_file.license.should == nil
    fontadapter.font_file.license_url.should == nil
    fontadapter.font_file.preferred_family.should == nil
    fontadapter.font_file.preferred_subfamily.should == nil
    fontadapter.font_file.compatible_full.should == nil
    fontadapter.font_file.sample_text.should == nil
  end

  it 'should extract correct name fields for Droid Sans' do
    fontadapter = FontAdapter.new(OTF_PATH)
    fontadapter.font_file.copyright.should == "Digitized data copyright \251 2007, Google Corporation."
    fontadapter.font_file.font_family.should == 'Droid Sans'
    fontadapter.font_file.font_subfamily.should == 'Regular'
    fontadapter.font_file.unique_font_id.should == 'Ascender - Droid Sans'
    fontadapter.font_file.full_name.should == 'Droid Sans'
    fontadapter.font_file.version.should == 'Version 1.00'
    fontadapter.font_file.postscript_name.should == 'DroidSans'
    fontadapter.font_file.trademark.should == 'Droid is a trademark of Google and may be registered in certain jurisdictions.'
    fontadapter.font_file.manufacturer.should == 'Ascender Corporation'
    fontadapter.font_file.designer.should == nil
    fontadapter.font_file.description.should == 'Droid Sans is a humanist sans serif typeface designed for user interfaces and electronic communication.'
    fontadapter.font_file.vendor_url.should == "\000h\000t\000t\000p\000:\000/\000/\000w\000w\000w\000.\000a\000s\000c\000e\000n\000d\000e\000r\000c\000o\000r\000p\000.\000c\000o\000m\000/"
    fontadapter.font_file.designer_url.should == "\000h\000t\000t\000p\000:\000/\000/\000w\000w\000w\000.\000a\000s\000c\000e\000n\000d\000e\000r\000c\000o\000r\000p\000.\000c\000o\000m\000/\000t\000y\000p\000e\000d\000e\000s\000i\000g\000n\000e\000r\000s\000.\000h\000t\000m\000l"
    fontadapter.font_file.license.should == 'Licensed under the Apache License, Version 2.0'
    fontadapter.font_file.license_url.should == 'http://www.apache.org/licenses/LICENSE-2.0'
    fontadapter.font_file.preferred_family.should == nil
    fontadapter.font_file.preferred_subfamily.should == nil
    fontadapter.font_file.compatible_full.should == 'Droid Sans'
    fontadapter.font_file.sample_text.should == nil
    fontadapter.font_file.findfont_name.should == nil
    fontadapter.font_file.wws_family.should == nil
    fontadapter.font_file.wws_subfamily.should == nil
  end

  it 'should extract correct name fields for Gentium' do
    fontadapter = FontAdapter.new(WOFF_PATH)
    fontadapter.font_file.copyright.should == 'Copyright (c) SIL International, 2003-2008.'
    fontadapter.font_file.font_family.should == 'Gentium Basic'
    fontadapter.font_file.font_subfamily.should == 'Regular'
    fontadapter.font_file.unique_font_id.should == 'SILInternational: Gentium Basic: 2008'
    fontadapter.font_file.full_name.should == 'Gentium Basic'
    fontadapter.font_file.version.should == 'Version 1.100'
    fontadapter.font_file.postscript_name.should == 'GentiumBasic'
    fontadapter.font_file.trademark.should == 'Gentium is a trademark of SIL International.'
    fontadapter.font_file.manufacturer.should == 'SIL International'
    fontadapter.font_file.designer.should == 'J. Victor Gaultney and Annie Olsen'
    fontadapter.font_file.description.should == nil
    fontadapter.font_file.vendor_url.should == 'http://scripts.sil.org/'
    fontadapter.font_file.designer_url.should == 'http://www.sil.org/~gaultney'
    fontadapter.font_file.license.should == "Copyright (c) 2003-2008, SIL International (http://www.sil.org/) with Reserved Font Names \"Gentium\" and \"SIL\".\r\n\r\nThis Font Software is licensed under the SIL Open Font License, Version 1.1. This license is copied below, and is also available with a FAQ at: http://scripts.sil.org/OFL\r\n\r\n\r\n-----------------------------------------------------------\r\nSIL OPEN FONT LICENSE Version 1.1 - 26 February 2007\r\n-----------------------------------------------------------\r\n\r\nPREAMBLE\r\nThe goals of the Open Font License (OFL) are to stimulate worldwide development of collaborative font projects, to support the font creation efforts of academic and linguistic communities, and to provide a free and open framework in which fonts may be shared and improved in partnership with others.\r\n\r\nThe OFL allows the licensed fonts to be used, studied, modified and redistributed freely as long as they are not sold by themselves. The fonts, including any derivative works, can be bundled, embedded, redistributed and/or sold with any software provided that any reserved names are not used by derivative works. The fonts and derivatives, however, cannot be released under any other type of license. The requirement for fonts to remain under this license does not apply to any document created using the fonts or their derivatives.\r\n\r\nDEFINITIONS\r\n\"Font Software\" refers to the set of files released by the Copyright Holder(s) under this license and clearly marked as such. This may include source files, build scripts and documentation.\r\n\r\n\"Reserved Font Name\" refers to any names specified as such after the copyright statement(s).\r\n\r\n\"Original Version\" refers to the collection of Font Software components as distributed by the Copyright Holder(s).\r\n\r\n\"Modified Version\" refers to any derivative made by adding to, deleting, or substituting -- in part or in whole -- any of the components of the Original Version, by changing formats or by porting the Font Software to a new environment.\r\n\r\n\"Author\" refers to any designer, engineer, programmer, technical writer or other person who contributed to the Font Software.\r\n\r\nPERMISSION & CONDITIONS\r\nPermission is hereby granted, free of charge, to any person obtaining a copy of the Font Software, to use, study, copy, merge, embed, modify, redistribute, and sell modified and unmodified copies of the Font Software, subject to the following conditions:\r\n\r\n1) Neither the Font Software nor any of its individual components, in Original or Modified Versions, may be sold by itself.\r\n\r\n2) Original or Modified Versions of the Font Software may be bundled, redistributed and/or sold with any software, provided that each copy contains the above copyright notice and this license. These can be included either as stand-alone text files, human-readable headers or in the appropriate machine-readable metadata fields within text or binary files as long as those fields can be easily viewed by the user.\r\n\r\n3) No Modified Version of the Font Software may use the Reserved Font Name(s) unless explicit written permission is granted by the corresponding Copyright Holder. This restriction only applies to the primary font name as presented to the users.\r\n\r\n4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font Software shall not be used to promote, endorse or advertise any Modified Version, except to acknowledge the contribution(s) of the Copyright Holder(s) and the Author(s) or with their explicit written permission.\r\n\r\n5) The Font Software, modified or unmodified, in part or in whole, must be distributed entirely under this license, and must not be distributed under any other license. The requirement for fonts to remain under this license does not apply to any document created using the Font Software.\r\n\r\nTERMINATION\r\nThis license becomes null and void if any of the above conditions are not met.\r\n\r\nDISCLAIMER\r\nTHE FONT SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM OTHER DEALINGS IN THE FONT SOFTWARE."
    fontadapter.font_file.license_url.should == 'http://scripts.sil.org/OFL'
    fontadapter.font_file.preferred_family.should == nil
    fontadapter.font_file.preferred_subfamily.should == nil
    fontadapter.font_file.compatible_full.should == 'Gentium Basic'
    fontadapter.font_file.sample_text.should == nil
    fontadapter.font_file.findfont_name.should == nil
    fontadapter.font_file.wws_family.should == nil
    fontadapter.font_file.wws_subfamily.should == nil
  end
end
