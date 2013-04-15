namespace :billing do
  desc 'Remove all billing jobs and reset subscription renewal dates.'
  task :fix_subscriptions => :environment do
    now = Time.now
    User.find_each(:batch_size => 100,
      :conditions => [
        'users.subscription_level > ? AND users.subscription_renewal < ?',
        0, now
      ]
    ) do |user|
      subscription_renewal = user.subscription_renewal
      user.destroy_billing_jobs
      while subscription_renewal < now do
        subscription_renewal = subscription_renewal + 1.month
      end
      user.reset_subscription_renewal(subscription_renewal)
    end
  end

  desc 'Recover missing gateway customer IDs from CSV file.'
  task :recover_customer_ids => :environment do
    csv_filename = ENV['CSV_FILE']
    gateway_ids = {}
    FasterCSV.foreach(csv_filename) do |row|
      email = row[5]
      id = row[0]
      gateway_ids[email] = id
    end
    User.find_each(:batch_size => 100,
      :conditions => ['users.subscription_level > ? AND users.gateway_customer_id IS NULL', 0]
    ) do |user|
      if gateway_ids[user.email]
        user.gateway_customer_id = gateway_ids[user.email]
        puts "Missing gateway ID (#{user.id}) found for #{user.email}."
        user.save
      end
    end
  end
end
