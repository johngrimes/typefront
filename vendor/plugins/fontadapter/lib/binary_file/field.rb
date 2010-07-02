module BinaryFile
  class Field
    UINT32 = 'N'
    UINT16 = 'n'
    UINT32_LE = 'V'
    UINT16_LE = 'v'
    STRING = 'a'
    DEFAULT_LENGTH = { 'N' => 4, 'n' => 2, 'V' => 4, 'v' => 2 }
    VALID_FORMATS = [UINT32, UINT16, UINT32_LE, UINT16_LE, STRING]

    attr_accessor :name, :format, :value
    attr_accessor :length, :length_field
    attr_accessor :offset, :offset_field

    def initialize(name, format, options = {})
      @name, @format = name, format
      @length, @length_field = options[:length], options[:length_field]
      @offset, @offset_field = options[:offset], options[:offset_field]
      @value_in, @value_test = options[:value_in], options[:value_test]
      assert_format_valid
      ensure_length_present
    end

    def check_value
      if @value_in
        if @value_test
          test = @value_in.select { |x| eval(@value_test) }
        else
          test = @value_in.include?(@value)
        end

        if test.blank?
          raise FileValidationError, "Field named '#{@name}' has value '#{@value}' that is not in the list of acceptable values: #{@value_in.inspect}"
        end
      end
    end

    def to_s
      @value.to_s
    end

    protected

    def assert_format_valid
      unless VALID_FORMATS.include?(@format)
        raise Exception, 'Attempt to create a field with an unknown format.'
      end
    end

    def ensure_length_present
      if !@length && !@length_field && !DEFAULT_LENGTH[@format]
        raise Exception, "Field with format of '#{@format}' must be accompanied by a specified length."
      end
    end
  end

  class FileValidationError < Exception
  end
end  
