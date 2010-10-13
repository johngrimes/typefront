class GenerateFormatJob
  @queue = :font_processing

  def self.perform(options = {})
    options.symbolize_keys!
    font = Font.find(options[:font_id])
    font.generate_format(options[:format], options[:description])
    font.update_attribute(:generate_jobs_pending, font.generate_jobs_pending - 1)
  end
end
