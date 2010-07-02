require 'binary_file/binary_file'

TTF_SFNT_VERSIONS = [
    0x00010000, # Version 1
    0x74727565, # Apple TrueType
    0x74797031  # 'typ1' - Type 1 PostScript
  ]

OTF_SFNT_VERSIONS = [
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
    'Zapf',
    'GSUB',
    'BASE',
    'GDEF',
    'GPOS'
  ]

OTF_TABLES = [
    'CFF ',
    'VORG',
    'EBDT',
    'EBLC',
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

PROPRIETARY_TABLES = [
    'LINO'
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

  ttf.define_table :table, :name_field => 'tag', :name_suffix => '_def', :repeats_field => 'offset.num_tables' do |table|
    table.tag :string, :length => 4
    table.checksum :uint32
    table.table_offset :uint32
    table.length :uint32
  end

  ttf.define_table :name, :offset_field => 'name_def.table_offset' do |name|
    name.format :uint16,
      :value_in => [0, 1]
    name.count :uint16
    name.string_offset :uint16
  end

  ttf.define_table :name_record, :name_field => 'name_id', :name_prefix => 'name_', :repeats_field => 'name.count' do |name_record|
    name_record.platform_id :uint16
    name_record.platform_specific_id :uint16
    name_record.language_id :uint16
    name_record.name_id :uint16
    name_record.length :uint16
    name_record.value_offset :uint16
    name_record.name_string :string,
      :offset_field => 'name_def.table_offset.value + name.string_offset.value + name_record.value_offset.value',
      :length_field => 'length'
  end

  ttf.define_alias :copyright, 'name_0.name_string.value'
  ttf.define_alias :font_family, 'name_1.name_string.value'
  ttf.define_alias :font_subfamily, 'name_2.name_string.value'
  ttf.define_alias :unique_font_id, 'name_3.name_string.value'
  ttf.define_alias :full_name, 'name_4.name_string.value'
  ttf.define_alias :version, 'name_5.name_string.value'
  ttf.define_alias :postscript_name, 'name_6.name_string.value'
  ttf.define_alias :trademark, 'name_7.name_string.value'
  ttf.define_alias :manufacturer, 'name_8.name_string.value'
  ttf.define_alias :designer, 'name_9.name_string.value'
  ttf.define_alias :description, 'name_10.name_string.value'
  ttf.define_alias :vendor_url, 'name_11.name_string.value'
  ttf.define_alias :designer_url, 'name_12.name_string.value'
  ttf.define_alias :license, 'name_13.name_string.value'
  ttf.define_alias :license_url, 'name_14.name_string.value'
  ttf.define_alias :preferred_family, 'name_16.name_string.value'
  ttf.define_alias :preferred_subfamily, 'name_17.name_string.value'
  ttf.define_alias :compatible_full, 'name_18.name_string.value'
  ttf.define_alias :sample_text, 'name_19.name_string.value'
end

BinaryFile::File.define :opentype_font_file do |otf|
  otf.define_table :offset do |offset|
    offset.scaler_type :uint32,
      :value_in => TTF_SFNT_VERSIONS + OTF_SFNT_VERSIONS
    offset.num_tables :uint16
    offset.search_range :uint16
    offset.entry_selector :uint16
    offset.range_shift :uint16
  end

  otf.define_table :table, :name_field => 'tag', :name_suffix => '_def', :repeats_field => 'offset.num_tables' do |table|
    table.tag :string, :length => 4
    table.checksum :uint32
    table.table_offset :uint32
    table.length :uint32
  end

  otf.define_table :name, :offset_field => 'name_def.table_offset' do |name|
    name.format :uint16,
      :value_in => [0, 1]
    name.count :uint16
    name.string_offset :uint16
  end

  otf.define_table :name_record, :name_field => 'name_id', :name_prefix => 'name_', :repeats_field => 'name.count' do |name_record|
    name_record.platform_id :uint16
    name_record.encoding_id :uint16
    name_record.language_id :uint16
    name_record.name_id :uint16
    name_record.length :uint16
    name_record.value_offset :uint16
    name_record.name_string :string,
      :offset_field => 'name_def.table_offset.value + name.string_offset.value + name_record.value_offset.value',
      :length_field => 'length'
  end

  otf.define_alias :copyright, 'name_0.name_string.value'
  otf.define_alias :font_family, 'name_1.name_string.value'
  otf.define_alias :font_subfamily, 'name_2.name_string.value'
  otf.define_alias :unique_font_id, 'name_3.name_string.value'
  otf.define_alias :full_name, 'name_4.name_string.value'
  otf.define_alias :version, 'name_5.name_string.value'
  otf.define_alias :postscript_name, 'name_6.name_string.value'
  otf.define_alias :trademark, 'name_7.name_string.value'
  otf.define_alias :manufacturer, 'name_8.name_string.value'
  otf.define_alias :designer, 'name_9.name_string.value'
  otf.define_alias :description, 'name_10.name_string.value'
  otf.define_alias :vendor_url, 'name_11.name_string.value'
  otf.define_alias :designer_url, 'name_12.name_string.value'
  otf.define_alias :license, 'name_13.name_string.value'
  otf.define_alias :license_url, 'name_14.name_string.value'
  otf.define_alias :preferred_family, 'name_16.name_string.value'
  otf.define_alias :preferred_subfamily, 'name_17.name_string.value'
  otf.define_alias :compatible_full, 'name_18.name_string.value'
  otf.define_alias :sample_text, 'name_19.name_string.value'
  otf.define_alias :findfont_name, 'name_20.name_string.value'
  otf.define_alias :wws_family, 'name_21.name_string.value'
  otf.define_alias :wws_subfamily, 'name_22.name_string.value'
end

BinaryFile::File.define :web_open_font_file do |woff|
  woff.define_table :header do |header|
    header.signature :uint32,
      :value_in => [0x774F4646]
    header.flavor :uint32,
      :value_in => TTF_SFNT_VERSIONS + OTF_SFNT_VERSIONS
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

  woff.define_table :directory, :name_field => 'tag', :name_suffix => '_def', :repeats_field => 'header.num_tables' do |directory|
    directory.tag :string, 
      :length => 4, 
      :value_in => TTF_TABLES + OTF_TABLES + GRAPHITE_TABLES + FONTFORGE_TABLES + PROPRIETARY_TABLES, 
      :value_test => 'value.upcase == x.upcase'
    directory.table_offset :uint32
    directory.comp_length :uint32
    directory.orig_length :uint32
    directory.orig_checksum :uint32
  end

  woff.define_table :name, :offset_field => 'name_def.table_offset', :compressed => true, :compressed_length_field => 'name_def.comp_length', :uncompressed_length_field => 'name_def.orig_length' do |name|
    name.format :uint16,
      :value_in => [0, 1]
    name.count :uint16
    name.string_offset :uint16
  end

  woff.define_table :name_record, :name_field => 'name_id', :name_prefix => 'name_', :repeats_field => 'name.count' do |name_record|
    name_record.platform_id :uint16
    name_record.encoding_id :uint16
    name_record.language_id :uint16
    name_record.name_id :uint16
    name_record.length :uint16
    name_record.value_offset :uint16
    name_record.name_string :string,
      :offset_field => 'name_def.table_offset.value + name.string_offset.value + name_record.value_offset.value',
      :length_field => 'length'
  end

  woff.define_alias :copyright, 'name_0.name_string.value'
  woff.define_alias :font_family, 'name_1.name_string.value'
  woff.define_alias :font_subfamily, 'name_2.name_string.value'
  woff.define_alias :unique_font_id, 'name_3.name_string.value'
  woff.define_alias :full_name, 'name_4.name_string.value'
  woff.define_alias :version, 'name_5.name_string.value'
  woff.define_alias :postscript_name, 'name_6.name_string.value'
  woff.define_alias :trademark, 'name_7.name_string.value'
  woff.define_alias :manufacturer, 'name_8.name_string.value'
  woff.define_alias :designer, 'name_9.name_string.value'
  woff.define_alias :description, 'name_10.name_string.value'
  woff.define_alias :vendor_url, 'name_11.name_string.value'
  woff.define_alias :designer_url, 'name_12.name_string.value'
  woff.define_alias :license, 'name_13.name_string.value'
  woff.define_alias :license_url, 'name_14.name_string.value'
  woff.define_alias :preferred_family, 'name_16.name_string.value'
  woff.define_alias :preferred_subfamily, 'name_17.name_string.value'
  woff.define_alias :compatible_full, 'name_18.name_string.value'
  woff.define_alias :sample_text, 'name_19.name_string.value'
  woff.define_alias :findfont_name, 'name_20.name_string.value'
  woff.define_alias :wws_family, 'name_21.name_string.value'
  woff.define_alias :wws_subfamily, 'name_22.name_string.value'
end

BinaryFile::File.define :extended_opentype_font_file_v1 do |eot|
  eot.define_table :header do |header|
    header.eot_size :uint32_le
    header.font_data_size :uint32_le
    header.version :uint32_le,
      :value_in => [0x00010000]
    header.flags :uint32_le
    header.font_panose :string,
      :length => 10
    header.charset :string,
      :length => 1
    header.italic :string,
      :length => 1
    header.weight :uint32_le
    header.fs_type :uint16_le
    header.magic_number :uint16_le,
      :value_in => [0x504C]
    header.unicode_range_1 :uint32_le
    header.unicode_range_2 :uint32_le
    header.unicode_range_3 :uint32_le
    header.unicode_range_4 :uint32_le
    header.code_page_range_1 :uint32_le
    header.code_page_range_2 :uint32_le
    header.checksum_adjustment :uint32_le
    header.reserved_1 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_2 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_3 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_4 :uint32_le,
      :value_in => [0x00000000]
    header.padding_1 :uint16_le,
      :value_in => [0x0000]
    header.family_name_size :uint16_le
    header.family_name :string,
      :length_field => 'family_name_size'
    header.padding_2 :uint16_le,
      :value_in => [0x0000]
    header.style_name_size :uint16_le
    header.style_name :string,
      :length_field => 'style_name_size'
    header.padding_3 :uint16_le,
      :value_in => [0x0000]
    header.version_name_size :uint16_le
    header.version_name :string,
      :length_field => 'version_name_size'
    header.padding_4 :uint16_le,
      :value_in => [0x0000]
    header.full_name_size :uint16_le
    header.full_name :string,
      :length_field => 'full_name_size'
    header.font_data :string,
      :length_field => 'font_data_size'
  end
end

BinaryFile::File.define :extended_opentype_font_file_v2 do |eot|
  eot.define_table :header do |header|
    header.eot_size :uint32_le
    header.font_data_size :uint32_le
    header.version :uint32_le,
      :value_in => [0x00020001]
    header.flags :uint32_le
    header.font_panose :string,
      :length => 10
    header.charset :string,
      :length => 1
    header.italic :string,
      :length => 1
    header.weight :uint32_le
    header.fs_type :uint16_le
    header.magic_number :uint16_le,
      :value_in => [0x504C]
    header.unicode_range_1 :uint32_le
    header.unicode_range_2 :uint32_le
    header.unicode_range_3 :uint32_le
    header.unicode_range_4 :uint32_le
    header.code_page_range_1 :uint32_le
    header.code_page_range_2 :uint32_le
    header.checksum_adjustment :uint32_le
    header.reserved_1 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_2 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_3 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_4 :uint32_le,
      :value_in => [0x00000000]
    header.padding_1 :uint16_le,
      :value_in => [0x0000]
    header.family_name_size :uint16_le
    header.family_name :string,
      :length_field => 'family_name_size'
    header.padding_2 :uint16_le,
      :value_in => [0x0000]
    header.style_name_size :uint16_le
    header.style_name :string,
      :length_field => 'style_name_size'
    header.padding_3 :uint16_le,
      :value_in => [0x0000]
    header.version_name_size :uint16_le
    header.version_name :string,
      :length_field => 'version_name_size'
    header.padding_4 :uint16_le,
      :value_in => [0x0000]
    header.full_name_size :uint16_le
    header.full_name :string,
      :length_field => 'full_name_size'
    header.padding_5 :uint16_le,
      :value_in => [0x0000]
    header.root_string_size :uint16_le
    header.root_string :string,
      :length_field => 'root_string_size'
    header.font_data :string,
      :length_field => 'font_data_size'
  end
end

BinaryFile::File.define :extended_opentype_font_file_v3 do |eot|
  eot.define_table :header do |header|
    header.eot_size :uint32_le
    header.font_data_size :uint32_le
    header.version :uint32_le,
      :value_in => [0x00020002]
    header.flags :uint32_le
    header.font_panose :string,
      :length => 10
    header.charset :string,
      :length => 1
    header.italic :string,
      :length => 1
    header.weight :uint32_le
    header.fs_type :uint16_le
    header.magic_number :uint16_le,
      :value_in => [0x504C]
    header.unicode_range_1 :uint32_le
    header.unicode_range_2 :uint32_le
    header.unicode_range_3 :uint32_le
    header.unicode_range_4 :uint32_le
    header.code_page_range_1 :uint32_le
    header.code_page_range_2 :uint32_le
    header.checksum_adjustment :uint32_le
    header.reserved_1 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_2 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_3 :uint32_le,
      :value_in => [0x00000000]
    header.reserved_4 :uint32_le,
      :value_in => [0x00000000]
    header.padding_1 :uint16_le,
      :value_in => [0x0000]
    header.family_name_size :uint16_le
    header.family_name :string,
      :length_field => 'family_name_size'
    header.padding_2 :uint16_le,
      :value_in => [0x0000]
    header.style_name_size :uint16_le
    header.style_name :string,
      :length_field => 'style_name_size'
    header.padding_3 :uint16_le,
      :value_in => [0x0000]
    header.version_name_size :uint16_le
    header.version_name :string,
      :length_field => 'version_name_size'
    header.padding_4 :uint16_le,
      :value_in => [0x0000]
    header.full_name_size :uint16_le
    header.full_name :string,
      :length_field => 'full_name_size'
    header.padding_5 :uint16_le,
      :value_in => [0x0000]
    header.root_string_size :uint16_le
    header.root_string :string,
      :length_field => 'root_string_size'
    header.root_string_checksum :uint32_le
    header.eudc_code_page :uint32_le
    header.padding_6 :uint16_le,
      :value_in => [0x0000]
    header.signature_size :uint16_le
    header.signature :string,
      :length_field => 'signature_size'
    header.eudc_flags :uint32_le
    header.eudc_font_size :uint32_le
    header.eudc_font_data :string,
      :length_field => 'eudc_font_size'
    header.font_data :string,
      :length_field => 'font_data_size'
  end
end
