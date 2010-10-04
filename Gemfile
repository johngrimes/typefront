source :rubygems

gem 'rails', '2.3.8'

gem 'pg'
gem 'sqlite3-ruby', '1.3.0', :require => 'sqlite3'

gem 'haml', '2.2.13'
gem 'compass', '0.8.17', :require => 'compass'
gem 'compass-960-plugin', '0.9.11', :require => 'ninesixty'

gem 'authlogic', '2.1.5'
gem 'smurf', '1.0.3'
gem 'paperclip', '2.3.3'
gem 'will_paginate', '2.3.14'
gem 'maruku', '0.6.0'
gem 'delayed_job', '2.0.3'

# ActiveMerchant dependencies
gem 'soap4r', '1.5.8'
gem 'money', '3.0.2'

# Rake task dependencies
gem 'fastercsv', '1.5.3'

gem 'newrelic_rpm'

group :development do
  gem 'capistrano'
  gem 'rvm'
end

group :test do
  gem 'rspec', '1.2.9'
  gem 'rspec-rails', '1.2.9'
  gem 'mocha', '0.9.8'
  gem 'factory_girl', '1.3.0'
end

group :staging, :production do
  gem 'unicorn'
end
