require 'binary_file/binary_file'

TTF_SFNT_VERSIONS = [
    0x00010000, # Version 1
    0x74727565, # Apple TrueType
    0x74797031  # 'typ1' - Type 1 PostScript
  ]

OTF_SFNT_VERSIONS = [
    0x00010000, # Version 1
    0x4F54544F  # 'OTTO' - CFF data
  ]

TTF_TABLES = [
    'acnt',
    'avar',
    'bdat',
    'bhed',
    'bloc',
    'bsln',
    'cmap',
    'cvar',
    'cvt ',
    'EBSC',
    'fdsc',
    'feat',
    'fmtx',
    'fpgm',
    'fvar',
    'gasp',
    'glyf',
    'gvar',
    'hdmx',
    'head',
    'hhea',
    'hmtx',
    'hsty',
    'just',
    'kern',
    'lcar',
    'loca',
    'maxp',
    'mort',
    'morx',
    'name',
    'opbd',
    'OS/2',
    'post',
    'prep',
    'prop',
    'trak',
    'vhea',
    'vmtx',
    'Zapf'
  ]

OTF_TABLES = [
    'CFF ',
    'VORG',
    'EBDT',
    'EBLC',
    'BASE',
    'GDEF',
    'GPOS',
    'GSUB',
    'JSTF',
    'DSIG',
    'LTSH',
    'PCLT',
    'VDMX'
  ]

GRAPHITE_TABLES = [
    'silf',
    'sile',
    'sill',
    'sild',
    'glat',
    'gloc'
  ]

FONTFORGE_TABLES = [
    'FFTM',
    'PfEd',
    'TeX ',
    'MATH'
  ]

BinaryFile::File.define :truetype_font_file do |ttf|
  ttf.define_table :offset do |offset|
    offset.scaler_type :uint32,
      :value_in => TTF_SFNT_VERSIONS
    offset.num_tables :uint16
    offset.search_range :uint16
    offset.entry_selector :uint16
    offset.range_shift :uint16
  end

  ttf.define_table :table, :repeats_field => 'offset.num_tables' do |table|
    table.tag :string, 
      :length => 4, 
      :value_in => TTF_TABLES + GRAPHITE_TABLES + FONTFORGE_TABLES,
      :value_test => 'value.upcase == x.upcase'
    table.checksum :uint32
    table.offset :uint32
    table.length :uint32
  end
end

BinaryFile::File.define :opentype_font_file do |otf|
  otf.define_table :offset do |offset|
    offset.scaler_type :uint32,
      :value_in => OTF_SFNT_VERSIONS
    offset.num_tables :uint16
    offset.search_range :uint16
    offset.entry_selector :uint16
    offset.range_shift :uint16
  end

  otf.define_table :table, :repeats_field => 'offset.num_tables' do |table|
    table.tag :string, 
      :length => 4, 
      :value_in => TTF_TABLES + OTF_TABLES + GRAPHITE_TABLES + FONTFORGE_TABLES,
      :value_test => 'value.upcase == x.upcase'
    table.checksum :uint32
    table.offset :uint32
    table.length :uint32
  end
end

BinaryFile::File.define :web_open_font_file do |woff|
  woff.define_table :header do |header|
    header.signature :uint32,
      :value_in => [0x774F4646]
    header.flavor :uint32,
      :value_in => OTF_SFNT_VERSIONS
    header.length :uint32
    header.num_tables :uint16
    header.reserved :uint16
    header.total_sfnt_size :uint32
    header.major_version :uint16
    header.minor_version :uint16
    header.meta_offset :uint32
    header.meta_length :uint32
    header.meta_orig_length :uint32
    header.priv_offset :uint32
    header.priv_length :uint32
  end

  woff.define_table :directory, :repeats_field => 'header.num_tables' do |directory|
    directory.tag :string, 
      :length => 4, 
      :value_in => TTF_TABLES + OTF_TABLES + GRAPHITE_TABLES + FONTFORGE_TABLES, 
      :value_test => 'value.upcase == x.upcase'
    directory.offset :uint32
    directory.comp_length :uint32
    directory.orig_length :uint32
    directory.orig_checksum :uint32
  end
end
