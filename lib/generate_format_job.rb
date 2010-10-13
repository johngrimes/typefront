# Delayed job for generating font formats
class GenerateFormatJob < Struct.new(:font_id, :format, :description)
  def perform
    font = Font.find(font_id)
    font.generate_format(format, description)
    font.update_attribute(:generate_jobs_pending, font.generate_jobs_pending - 1)
  end
end
