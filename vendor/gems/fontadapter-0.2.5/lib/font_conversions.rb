require 'tmpdir'

module FontConversions
  def FontConversions.sfnt_to_woff(source, output)
    temp_source = temp_location(source)
    FileUtils.copy(source, temp_source)
    temp_output = sfnt2woff_output(temp_source)

    `sfnt2woff "#{temp_source}"`
    if $? == 0
      FileUtils.copy(temp_output, output)
      FileUtils.rm(temp_source)
      true
    else
      raise Exception, "There was a problem converting the TrueType or OpenType file to WOFF: #$?"
    end
  end

  def FontConversions.woff_to_otf(source, output)
    `woff2sfnt "#{source}" > "#{output}"`
    if $? == 0
      true
    else
      raise Exception, "There was a problem converting the WOFF file to OTF: #$?"
    end
  end

  def FontConversions.otf_to_ttf(source, output)
    temp_source = temp_location(source)
    FileUtils.copy(source, temp_source)
    temp_output = otf2ttf_output(temp_source)

    `otf2ttf.pe "#{temp_source}"`
    if $? == 0
      FileUtils.copy(temp_output, output)
      FileUtils.rm(temp_source)
      true
    else
      raise Exception, "There was a problem converting the OpenType file to TrueType: #$?"
    end
  end

  def FontConversions.ttf_to_eot(source, output)
    `ttf2eot "#{source}" > "#{output}"`
    true
  end

  def FontConversions.temp_location(path)
    temp_dir = Dir::tmpdir || '/tmp'
    File.expand_path(temp_dir + '/conv_' + File.basename(path))
  end

  def FontConversions.sfnt2woff_output(path)
    File.expand_path(File.dirname(path) + '/' + File.basename_without_ext(path) + '.woff')
  end

  def FontConversions.otf2ttf_output(path)
    File.expand_path(File.dirname(path) + '/' + File.basename_without_ext(path, :case_insensitive => true) + '.ttf')
  end
end

class File
  def File.basename_without_ext(file_name, options = {})
    basename = File.basename(file_name).gsub(/\.ttf\Z/, '').gsub(/\.otf\Z/, '')
    if options[:case_insensitive]
      basename = basename.gsub(/\.TTF\Z/, '').gsub(/\.OTF\Z/, '')
    end
    basename
  end
end

# alias old_backquote `
# def `(cmd)
#   result = old_backquote(cmd)
#   puts "COMMAND: #{cmd}"
#   result
# end
