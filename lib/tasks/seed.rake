PRIMARY_FONT_FAMILY = 'Droid Sans'
PRIMARY_FONT_SUBFAMILY = 'Regular'
PRIMARY_FONT_FILENAME = 'DroidSans.ttf'
SECONDARY_FONT_FAMILY = 'Droid Sans'
SECONDARY_FONT_SUBFAMILY = 'Bold'
SECONDARY_FONT_FILENAME = 'DroidSans-Bold.ttf'
MONOSPACE_FONT_FAMILY = 'Droid Sans Mono'
MONOSPACE_FONT_SUBFAMILY = 'Regular'
MONOSPACE_FONT_FILENAME = 'DroidSansMono.ttf'
 
namespace :db do
  task :seed => :environment do
    primary_font = Font.find_by_id(1)
    secondary_font = Font.find_by_id(2)
    monospace_font = Font.find_by_id(3)

    if primary_font && 
        (primary_font.font_family != PRIMARY_FONT_FAMILY ||
        primary_font.font_subfamily != PRIMARY_FONT_SUBFAMILY)
      raise Exception, "Font in primary font position not #{PRIMARY_FONT_FAMILY} #{PRIMARY_FONT_SUBFAMILY}"
    end
    if secondary_font && 
        (secondary_font.font_family != SECONDARY_FONT_FAMILY ||
        secondary_font.font_subfamily != SECONDARY_FONT_SUBFAMILY)
      raise Exception, "Font in secondary font position not #{SECONDARY_FONT_FAMILY} #{SECONDARY_FONT_SUBFAMILY}"
    end
    if monospace_font && 
        (monospace_font.font_family != MONOSPACE_FONT_FAMILY ||
        monospace_font.font_subfamily != MONOSPACE_FONT_SUBFAMILY)
      raise Exception, "Font in monospace font position not #{MONOSPACE_FONT_FAMILY} #{MONOSPACE_FONT_SUBFAMILY}"
    end

    if !primary_font
      primary_font = Font.new
      primary_font.id = 1
      primary_font.original = File.new("#{RAILS_ROOT}/spec/fixtures/#{PRIMARY_FONT_FILENAME}")
      primary_font.save!(:validate => false)
    end
    if !secondary_font
      secondary_font = Font.new
      secondary_font.id = 2
      secondary_font.original = File.new("#{RAILS_ROOT}/spec/fixtures/#{SECONDARY_FONT_FILENAME}")
      secondary_font.save!(:validate => false)
    end
    if !monospace_font
      monospace_font = Font.new
      monospace_font.id = 3
      monospace_font.original = File.new("#{RAILS_ROOT}/spec/fixtures/#{MONOSPACE_FONT_FILENAME}")
      monospace_font.save!(:validate => false)
    end
  end
end

