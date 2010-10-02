set :application, 'typefront'
set :repository,  'git@github.com:smallspark/typefront.git'
set :scm, 'git'

if ENV['branch']
  set :branch, ENV['branch']
end

set :user, 'www'
set :runner, 'www'

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

after 'deploy:setup', 'typefront:set_permissions'

after 'deploy:update_code', 
  'typefront:set_permissions',
  'typefront:create_symlinks',
  'typefront:create_failed_fonts',
  'typefront:run_tests'

after 'deploy', 'deploy:cleanup'

namespace :deploy do
  task :restart do
    sudo "service unicorn-typefront-#{environment} restart"
  end
end

namespace :typefront do
  task :create_symlinks, :roles => :web do
    # Create symbolic link to a common database.yml file in the shared directory,
    # which is not under source control
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :create_failed_fonts, :roles => :web do
    # Make sure failed fonts directory exists
    run "mkdir -p #{release_path}/public/system/failed_fonts/test"
  end

  task :run_tests, :roles => :web do
    # Make sure gems and database schema are up to date
    run "cd #{release_path} && bundle install"
    run "cd #{release_path} && rake db:migrate RAILS_ENV=development"
    run "cd #{release_path} && rake db:seed RAILS_ENV=development"
    run "cd #{release_path} && rake db:migrate RAILS_ENV=#{environment}"
    run "cd #{release_path} && rake db:seed RAILS_ENV=#{environment}"

    # Make sure all tests pass
    run "cd #{release_path} && rake db:test:prepare"
    run "cd #{release_path} && rake spec"
  end

  task :set_permissions do
    sudo "chown -R www:www #{deploy_to}"
    sudo "chmod -R g+w #{deploy_to}"
  end
end
