require 'systemu'
require 'tmpdir'

module FontConversions
  OPTIMIZE_PATH = File.join(File.dirname(__FILE__), '..', 'script', 'optimize.pe')
  OPTIMIZE_WITHOUT_HINTING_PATH = File.join(File.dirname(__FILE__), '..', 'script', 'optimize_without_hinting.pe')

  def FontConversions.sfnt_to_woff(source, output, options = {})
    temp_source = temp_location(source)
    FileUtils.copy(source, temp_source)
    temp_output = sfnt2woff_output(temp_source)

    command_output = `sfnt2woff "#{temp_source}"`

    FileUtils.copy(temp_output, output)
    FileUtils.rm [temp_source, temp_output]
    return command_output
  end

  def FontConversions.woff_to_sfnt(source, output, options = {})
    `woff2sfnt "#{source}" > "#{output}"`
  end

  def FontConversions.sfnt_to_ttf(source, output, options = {})
    `#{optimize_path(options)} "#{source}" "#{output}"`
  end

  def FontConversions.sfnt_to_otf(source, output, options = {})
    `#{optimize_path(options)} "#{source}" "#{output}"`
  end

  def FontConversions.ttf_to_eot(source, output, options = {})
    `ttf2eot "#{source}" > "#{output}"`
  end

  def FontConversions.ttf_to_svg(source, output, options = {})
    `ttf2svg "#{source}" -o "#{output}"`
  end

  def FontConversions.optimize_path(options = {})
    options[:autohinting_enabled] ? OPTIMIZE_PATH : OPTIMIZE_WITHOUT_HINTING_PATH
  end

  def FontConversions.temp_location(path)
    temp_dir = Dir::tmpdir || '/tmp'
    File.expand_path(temp_dir + '/conv_' + File.basename(path))
  end

  def FontConversions.sfnt2woff_output(path)
    File.expand_path(File.dirname(path) + '/' + File.basename_without_ext(path) + '.woff')
  end

  def FontConversions.otf2ttf_output(path)
    File.expand_path(File.dirname(path) + '/' + File.basename_without_ext(path) + '.ttf')
  end
end

class File
  def File.basename_without_ext(file_name)
    File.basename(file_name).split('.').first
  end
end

# Run all font conversion commands with nice
alias old_backquote `
def `(cmd)
  output = "** COMMAND: #{cmd}\n"
  status = systemu 'nice ' + cmd, 'stdout' => output, 'stderr' => output
  raise FontConversionException, output unless status.success?
  return output
end

class FontConversionException < Exception
end
