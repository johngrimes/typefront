namespace :stats do
  desc 'Generate a bunch of dummy users that joined over the last 3 months'
  task :generate_test_users => :environment do
    n = 200

    n.times do
      u = User.new
      u.created_at = 3.months.ago + (rand(90) + 1).days + 2.hours
      u.subscription_level = rand(3)
      u.active = rand(2)
      u.send(:create_without_callbacks)
    end
  end

  desc 'Generate a bunch of dummy requests over the last 3 months'
  task :generate_test_requests => :environment do
    n = 20000

    n.times do
      r = LoggedRequest.new
      r.created_at = 3.months.ago + (rand(90) + 1).days + 5.hours
      formats = ['ttf', 'otf', 'eot', 'woff', 'svg']
      r.format = formats[rand(5)]
      r.response_time = rand(30) * 0.01
      r.send(:create_without_callbacks)
    end
  end
end 
