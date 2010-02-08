require 'rubygems'
require 'active_support'
require 'zlib'
require 'binary_file/field'
require 'binary_file/table'

module BinaryFile
  class File < File
    @table_defs = []

    class << self; attr_accessor :table_defs end
    attr_reader :data

    def File.define(name)
      new_class_name = name.to_s.camelize
      subclass_def = %Q!
        class #{new_class_name} < BinaryFile::File
          @table_defs = []
        end
      !
      BinaryFile.module_eval(subclass_def)
      yield(eval(new_class_name))
    end

    def File.define_table(name, options = {})
      new_table_def = TableDefinition.new(name.to_s, options)
      yield(new_table_def)
      @table_defs << new_table_def
    end

    def File.define_alias(name, target)
      method_def = %Q!
        def #{name}
          return #{target}
        rescue NoMethodError
          return nil
        end
      !
      BinaryFile::File.class_eval(method_def)
    end

    def File.open(filename, mode = 'r')
      new(::File.open(filename, "rb") { |file| file.read })
    end

    def File.to_s
      output = ''
      @table_defs.each do |table_def|
        output << "\n#{table_def.name.upcase}\n"
        output << table_def.to_s
      end
      output << "\n"
      output
    end

    def initialize(data)
      @tables = []
      @data = StringIO.new(data)
      parse_data
    end

    def tables
      @tables
    end

    def method_missing(name)
      if table = @tables.select { |x| x.name == name.to_s }.first
        table
      else
        raise NoMethodError, "undefined method '#{name}'"
      end
    end

    def to_s
      output = ''
      @tables.each do |table|
        output << "\n#{table.name}\n"
        output << table.to_s
      end
      output << "\n"
      output
    end

    protected

    def parse_data
      data.pos = 0

      self.class.table_defs.each do |table_def|
        if table_def.offset
          data.pos = table_def.offset
        end
        if table_def.offset_field
          data.pos = eval("#{table_def.offset_field}.value")
        end

        if table_def.compressed
          compressed_length = eval("#{table_def.compressed_length_field}.value")
          uncompressed_length = eval("#{table_def.uncompressed_length_field}.value")
          if compressed_length < uncompressed_length
            decompress_block(eval("#{table_def.compressed_length_field}.value"))
          end
        end

        repeats = table_def.repeats || (table_def.repeats_field ? eval(table_def.repeats_field + '.value') : nil) || 1

        repeats.times do
          table = table_def.spawn_table

          table.fields.each do |field|
            if field.offset || field.offset_field
              prev_pos = data.pos
              data.pos = field.offset || eval(field.offset_field.gsub("#{table_def.name}", 'table'))
            end

            read_length = field.length || (field.length_field ? eval("table.#{field.length_field}").value : nil) || Field::DEFAULT_LENGTH[field.format]
            format_length = (field.length || (field.length_field ? eval("table.#{field.length_field}").value : nil) || '').to_s
            read_data = data.read(read_length)
            field.value = read_data.nil? ? nil : read_data.unpack(field.format + format_length).first
            field.check_value

            if field.offset || field.offset_field
              data.pos = prev_pos
            end
          end

          if table_def.name_field
            prefix = table_def.name_prefix || ''
            suffix = table_def.name_suffix || ''
            table.name = prefix + eval("table.#{table_def.name_field}").value.to_s + suffix
          end

          @tables << table
        end
      end
    end

    def decompress_block(length)
      prev_pos = data.pos
      compressed_data = data.read(length)
      uncompressed_data = Zlib::Inflate.inflate(compressed_data)
      new_data = data.string[0..(prev_pos - 1)] + uncompressed_data + data.string[(prev_pos + compressed_data.length)..(data.string.length - 1)]
      data.string = new_data
      data.pos = prev_pos
    end
  end
end
