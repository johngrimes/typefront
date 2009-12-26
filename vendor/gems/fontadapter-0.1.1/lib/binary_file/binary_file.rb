require 'rubygems'
require 'active_support'
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
        output << "\n#{table.name.upcase}\n"
        output << table.to_s
      end
      output << "\n"
      output
    end

    protected

    def parse_data
      data.pos = 0
      self.class.table_defs.each do |table_def|
        repeats = table_def.repeats || (table_def.repeats_field ? eval(table_def.repeats_field + '.value') : nil) || 1
        repeats.times do
          table = table_def.spawn_table
          table.fields.each do |field|
            read_length = field.length || Field::DEFAULT_LENGTH[field.format]
            format_length = field.length ? field.length.to_s : ''
            field.value = data.read(read_length).unpack(field.format + format_length).first
            field.check_value
          end
          @tables << table
        end
      end
    end
  end
end
