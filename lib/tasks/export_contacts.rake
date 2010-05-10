require 'fastercsv'

namespace :typefront do
  namespace :contacts do
    desc 'Export email addresses of users to contacts.csv'
    task :export => :environment do
      contacts = User.all

      FasterCSV.open("#{RAILS_ROOT}/contacts.csv", 'w') do |csv|
        contacts.each do |contact|
          output_row = Array.new
          output_row[0] = contact.email
          output_row[1] = contact.first_name
          output_row[2] = contact.last_name
          csv << output_row
        end
      end
    end
  end
end
