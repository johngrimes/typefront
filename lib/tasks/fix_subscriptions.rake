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

  desc 'Populate missing credit card fields using eWAY API.'
  task :populate_missing_cc_fields => :environment do
    config_file = File.join(Rails.root, 'config', 'gateway_config.yml')
    config = GATEWAY_CONFIG
    eway = BigCharger.new(
      config[:customer_id], config[:username],
      config[:password], config[:test_mode]
    )
    User.find_each(:batch_size => 100,
      :conditions => ['users.subscription_level > ? AND (users.card_type ' +
        'IS NULL OR users.card_name IS NULL OR users.card_expiry IS NULL)', 0]
    ) do |user|
      if user.gateway_customer_id.blank?
        puts "User (#{user.id}) has no gateway customer ID."
      else
        customer = eway.query_customer(user.gateway_customer_id)
        user.cc_name = customer['CCName'] if user.cc_name.blank?
        if user.cc_expiry.blank?
          user.cc_expiry = Time.parse(
            "#{customer['CCExpiryYear']}-#{customer['CCExpiryMonth']}-01"
          )
        end
        user.cc_type = 'visa' if cc_type.blank?
        user.save!
        puts "CC details updated: cc_name=#{user.cc_name}, " +
          "cc_expiry=#{user.cc_expiry}, cc_type=#{user.cc_type}"
      end
    end
  end
end
