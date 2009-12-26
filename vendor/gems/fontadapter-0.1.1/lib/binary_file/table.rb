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
    attr_accessor :repeats, :repeats_field

    def initialize(name, options = {})
      super(name)
      @repeats, @repeats_field = options[:repeats], options[:repeats_field]
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
