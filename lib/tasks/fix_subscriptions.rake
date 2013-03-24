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
      user.clear_all_billing
      while subscription_renewal < now do
        subscription_renewal = subscription_renewal + 1.month
      end
      user.reset_subscription_renewal(subscription_renewal)
    end
  end
end
