require 'fastercsv'

namespace :contacts do
  namespace :export do
    desc 'Export email addresses of users to mailchimp_contacts.csv'
    task :mailchimp => :environment do
      contacts = User.all

      FasterCSV.open("#{RAILS_ROOT}/contacts_mailchimp.csv", 'w') do |csv|
        contacts.each do |contact|
          output_row = Array.new
          output_row[0] = contact.email
          output_row[1] = contact.first_name
          output_row[2] = contact.last_name
          csv << output_row
        end
      end
    end

    desc 'Export email addresses of users to google_contacts.csv'
    task :google => :environment do
      contacts = User.all

      FasterCSV.open("#{RAILS_ROOT}/contacts_google.csv", 'w') do |csv|
        labels = ['Name', 'Given Name', 'Family Name', 'Group Membership', 'E-mail 1 - Type', 'E-mail 1 - Value']
        csv << labels

        contacts.each do |contact|
          output_row = Array.new
          output_row[0] = contact.full_name
          output_row[1] = contact.first_name
          output_row[2] = contact.last_name
          output_row[3] = contact.subscription_level > 0 ? '* Paying Users' : '* Free Users'
          output_row[4] = '* Home'
          output_row[5] = contact.email
          csv << output_row
        end
      end
    end
  end
end
