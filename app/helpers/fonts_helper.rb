module FontsHelper
  def include_code(font, options = {})
    include_code = ''
    eot_format = font.format(:eot, :raise_error => false)
    woff_format = font.format(:woff, :raise_error => false)
    otf_format = font.format(:otf, :raise_error => false)

    if eot_format
      if options[:include_markup]
        include_code << '<span class="eot-code">'
      end
      include_code << "@font-face {\n"
      include_code << "  font-family: \"#{font.font_family}\";\n"
      include_code << "  url(#{font_path(:id => font.id, :format => 'eot')});\n"
      include_code << "}"
      if options[:include_markup]
        include_code << '</span>'
      end
    end

    if otf_format || woff_format
      if options[:include_markup]
        include_code << '<span class="eot-woffotf-separator">'
      end
      include_code << "\n\n"
      if options[:include_markup]
        include_code << '</span>'
      end
      if options[:include_markup]
        include_code << '<span class="otf-woff-code">'
      end
      include_code << "@font-face {\n"
      include_code << "  font-family: \"#{font.font_family}\";\n"
      include_code << "  src: "
      include_code << "local(\"#{font.font_family}\")"
      if options[:include_markup]
        include_code << '<span class="local-separator">'
      end
      include_code << ",\n       "
      if options[:include_markup]
        include_code << '</span>'
      end

      if woff_format
        if options[:include_markup]
          include_code << '<span class="woff-code">'
        end
        include_code << "url(#{font_path(:id => font.id, :format => 'woff')}) format(\"woff\")"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if woff_format && otf_format
        if options[:include_markup]
          include_code << '<span class="woff-otf-separator">'
        end
        include_code << ",\n       "
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if otf_format
        if options[:include_markup]
          include_code << '<span class="otf-code">'
        end
        include_code << "url(#{font_path(:id => font.id, :format => 'otf')}) format(\"opentype\")"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      include_code << ";\n}"
      
      if options[:include_markup]
        include_code << '</span>'
      end
    end
  end
end
