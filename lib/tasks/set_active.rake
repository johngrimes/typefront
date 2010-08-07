namespace :formats do
  desc 'Activate all formats in database'
  task :set_all_to_active => :environment do
    formats = Format.all

    formats.each do |format|
      format.active = true
      format.save!
    end
  end
end
