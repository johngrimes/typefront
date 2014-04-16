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
set :deploy_to, '/var/www/sites/typefront-staging'

environment = 'staging'

task :to_staging do
  set :deploy_to, '/var/www/sites/typefront-staging'
  environment = 'staging'
end

task :to_prod do
  set :deploy_to, '/var/www/sites/typefront'
  environment = 'production'
end

namespace :deploy do
  task :cold, :roles => :web do
    update
    update_bundle
    create_symlinks
    load_schema
    seed
    create_failed_fonts
    run_tests
  end

  task :default, :roles => :web do
    update
    update_bundle
    create_symlinks
    migrate
    seed
    create_failed_fonts
    run_tests
    restart
  end

  task :update_bundle, :roles => :web do
    run "ln -nfs #{shared_path}/bundle #{release_path}/vendor"
    run "cd #{release_path} && bundle install --deployment"
  end

  task :load_schema, :roles => :web do
    run "cd #{release_path} && rake db:schema:load RAILS_ENV=development"
    run "cd #{release_path} && rake db:schema:load RAILS_ENV=#{environment}"
  end

  task :migrate, :roles => :web do
    run "cd #{release_path} && rake db:migrate RAILS_ENV=development"
    run "cd #{release_path} && rake db:migrate RAILS_ENV=#{environment}"
  end

  task :seed, :roles => :web do
    run "cd #{release_path} && rake db:seed RAILS_ENV=development"
    run "cd #{release_path} && rake db:seed RAILS_ENV=#{environment}"
  end

  task :create_symlinks, :roles => :web do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/unicorn#{environment == 'staging' ? '-staging' : ''}.rb #{release_path}/config/unicorn#{environment == 'staging' ? '-staging' : ''}.rb"
  end

  task :create_failed_fonts, :roles => :web do
    run "mkdir -p #{release_path}/public/system/failed_fonts/test"
  end

  task :run_tests, :roles => :web do
    run "cd #{release_path} && rake db:test:prepare"
    run "cd #{release_path} && rake spec"
  end

  task :restart, :roles => :web do
    run "kill -HUP `cat #{shared_path}/pids/unicorn.pid`"
  end
end

after 'deploy', 'deploy:cleanup'
