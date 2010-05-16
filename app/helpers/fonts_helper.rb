module FontsHelper
  def include_code(font, options = {})
    include_code = ''
    svg_format = font.format(:svg, :raise_error => false)
    eot_format = font.format(:eot, :raise_error => false)
    woff_format = font.format(:woff, :raise_error => false)
    otf_format = font.format(:otf, :raise_error => false)
    ttf_format = font.format(:ttf, :raise_error => false)
    font_family = font.font_family
    if font_family && options[:unique_font_names]
      font_family = font_family + " #{font.id}"
    end

    if ttf_format || otf_format || woff_format || eot_format || svg_format
      include_code << "@font-face {\n"
      include_code << "  font-family: '#{font_family}';\n"

      if eot_format
        if options[:include_markup]
          include_code << '<span class="eot-code">'
        end
        include_code << "  src: url('#{$HOST}#{font_path(:id => font.id, :format => 'eot')}');\n"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if ttf_format || otf_format || woff_format || svg_format
        if options[:include_markup]
          include_code << '<span class="noneot-code">'
        end
        include_code << "  src: local('☺'),\n       "
      end

      if woff_format
        if options[:include_markup]
          include_code << '<span class="woff-code">'
        end
        include_code << "url('#{$HOST}#{font_path(:id => font.id, :format => 'woff')}') format('woff')"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if woff_format && (ttf_format || otf_format || svg_format)
        if options[:include_markup]
          include_code << '<span class="woff-ttf-separator">'
        end
        include_code << ",\n       "
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if ttf_format
        if options[:include_markup]
          include_code << '<span class="ttf-code">'
        end
        include_code << "url('#{$HOST}#{font_path(:id => font.id, :format => 'ttf')}') format('truetype')"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if ttf_format && (otf_format || svg_format)
        if options[:include_markup]
          include_code << '<span class="ttf-otf-separator">'
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
        include_code << "url('#{$HOST}#{font_path(:id => font.id, :format => 'otf')}') format('opentype')"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if otf_format && svg_format
        if options[:include_markup]
          include_code << '<span class="otf-svg-separator">'
        end
        include_code << ",\n       "
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if svg_format
        if options[:include_markup]
          include_code << '<span class="svg-code">'
        end
        include_code << "url('#{$HOST}#{font_path(:id => font.id, :format => 'svg')}') format('svg')"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      if ttf_format || otf_format || woff_format || svg_format
        include_code << ";\n"
        if options[:include_markup]
          include_code << '</span>'
        end
      end

      include_code << style_descriptors(font, options) 
      include_code << "}"
      
      if options[:include_markup]
        include_code << '</span>'
      end
    end
    return include_code
  end

  def style_descriptors(font, options = {})
    style_descriptors = ''

    unless font.font_subfamily.blank?

      if options[:include_markup]
        style_descriptors << '<span class="style-descriptors">'
      end
      if font.font_subfamily.downcase =~ /semibold/
        style_descriptors << "  font-weight: 500;\n"
      elsif font.font_subfamily.downcase =~ /bold/
        style_descriptors << "  font-weight: bold;\n"
      else
        style_descriptors << "  font-weight: normal;\n"
      end
      if font.font_subfamily.downcase =~ /italic/
        style_descriptors << "  font-style: italic;\n"
      else
        style_descriptors << "  font-style: normal;\n"
      end
      if options[:include_markup]
        style_descriptors << '</span>'
      end

    end

    return style_descriptors
  end
end
