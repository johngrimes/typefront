require 'rvm/capistrano'

set :application, 'typefront'
set :repository,  'git@github.com:smallspark/typefront.git'
set :scm, 'git'
set :rvm_ruby_string, '1.8.7@typefront'

if ENV['branch']
  set :branch, ENV['branch']
end

set :user, 'www'
set :runner, 'www'
set :use_sudo, false

role :web, '74.207.246.230'
set :deploy_to, '/var/www/sites/typefront'

environment = 'staging'

task :to_staging do
  set :deploy_to, '/var/www/sites/typefront-staging'
  environment = 'staging'
end

task :to_prod do
  set :deploy_to, '/var/www/sites/typefront'
  environment = 'production'
end

after 'deploy:update_code', 
  'typefront:create_symlinks',
  'typefront:create_failed_fonts',
  'typefront:run_tests'

after 'deploy', 'deploy:cleanup'

namespace :deploy do
  task :restart do
    run "rm #{shared_path}/pids/unicorn.pid"
  end
end

namespace :typefront do
  task :create_symlinks, :roles => :web do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
  end

  task :create_failed_fonts, :roles => :web do
    # Make sure failed fonts directory exists
    run "mkdir -p #{release_path}/public/system/failed_fonts/test"
  end

  task :run_tests, :roles => :web do
    # Make sure bundle and database schema are up to date
    run "cd #{release_path} && bundle install --deployment"
    run "cd #{release_path} && rake db:migrate RAILS_ENV=development"
    run "cd #{release_path} && rake db:seed RAILS_ENV=development"
    run "cd #{release_path} && rake db:migrate RAILS_ENV=#{environment}"
    run "cd #{release_path} && rake db:seed RAILS_ENV=#{environment}"

    # Make sure all tests pass
    run "cd #{release_path} && rake db:test:prepare"
    run "cd #{release_path} && rake spec"
  end
end
