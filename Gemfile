source :rubygems

gem 'rails', '2.3.11'

# Database
gem 'pg'
gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'rails_sql_views'

gem 'haml'
gem 'compass', '0.8.17', :require => 'compass'
gem 'compass-960-plugin', '0.9.11', :require => 'ninesixty'

gem 'authlogic'
gem 'paperclip'
gem 'will_paginate'
gem 'maruku'
gem 'smurf'

# Job processing
gem 'resque'
gem 'resque-scheduler', :require => 'resque_scheduler'
gem 'SystemTimer'
gem 'systemu'

# Payments
gem 'bigcharger', :git => 'git@github.com:johngrimes/bigcharger.git'
gem 'credit_card_validator'

# Rake task dependencies
gem 'fastercsv'

group :development do
  gem 'capistrano'
  gem 'rvm'
end

group :test do
  gem 'rspec', '1.2.9'
  gem 'rspec-rails', '1.2.9'
  gem 'mocha'
  gem 'factory_girl'
  gem 'rcov'
  gem 'ruby-debug'
end

group :staging, :production do
  gem 'unicorn'
end
