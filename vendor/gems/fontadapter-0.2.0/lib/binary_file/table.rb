module BinaryFile
  class Table
    attr_accessor :name, :fields

    def initialize(name)
      @name = name
      @fields = []
    end

    def method_missing(name, *args)
      if field = @fields.select { |x| x.name == name }.first
        field
      else
        raise NoMethodError, "undefined method '#{name}'"
      end
    end

    def to_s
      output = ''
      @fields.each do |field|
        output << "#{field.name}: #{field.value.to_s}\n"
      end
      output
    end
  end

  class TableDefinition < Table
    attr_accessor :name_field, :name_prefix, :name_suffix
    attr_accessor :offset, :offset_field
    attr_accessor :repeats, :repeats_field
    attr_accessor :compressed, :compressed_length_field, :uncompressed_length_field

    def initialize(name, options = {})
      super(name)
      @name_field, @name_prefix, @name_suffix = options[:name_field], options[:name_prefix], options[:name_suffix]
      @offset, @offset_field = options[:offset], options[:offset_field]
      @repeats, @repeats_field = options[:repeats], options[:repeats_field]
      @compressed, @compressed_length_field, @uncompressed_length_field = options[:compressed], options[:compressed_length_field], options[:uncompressed_length_field]
    end

    def fields
      @fields
    end

    def spawn_table
      new_table = Table.new(name)
      @fields.each do |field|
        new_table.fields << field.clone
      end
      new_table
    end

    def add_field(name, format, options = {})
      new_field = Field.new(name, eval('Field::' + format.to_s.upcase), options)
      @fields << new_field
    end
    
    def method_missing(name, *args)
      add_field(name, args[0], args[1] || {})
    end

    def to_s
      output = ''
      @fields.each do |field|
        output << "#{field.name} (#{field.format})\n"
      end
      output
    end
  end
end
