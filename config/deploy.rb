set :application, "typefront"
set :repository,  "git@github.com:johngrimes/typefront.git"
set :scm, "git"

if ENV['branch']
  set :branch, ENV['branch']
end

set :user, "deploy"
set :runner, "deploy"

role :web, "74.207.246.162"
set :deploy_to, "/var/www/sites/typefront.com"

environment = 'staging'

task :to_staging do
  role :web, "74.207.246.162"
  set :deploy_to, "/var/www/sites/staging.typefront.com"
  environment = 'staging'
end

task :to_prod do
  role :web, "74.207.246.162"
  set :deploy_to, "/var/www/sites/typefront.com"
  environment = 'production'
end

# Remove all but 5 deployed releases after each deployment
after :deploy, 'set_permissions'
after :deploy, 'deploy:cleanup'

namespace :deploy do
  task :restart do
    sudo "service thin-typefront-#{environment} stop"
    sudo "service thin-typefront-#{environment} start"
  end
end

task :after_update_code, :roles => :web do
  set_permissions

  # Create symbolic link to a common database.yml file in the shared directory,
  # which is not under source control
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"

  # Symlink to rake task for controlling thin cluster
  run "ln -nfs #{deploy_to}/../common/tasks/thin.rake #{release_path}/lib/tasks/thin.rake"

  # Make sure gems and database schema are up to date
  run "cd #{release_path}; rake db:migrate RAILS_ENV=development"
  run "cd #{release_path}; rake db:migrate RAILS_ENV=#{environment}"

  # Compile Compass stylesheets
  run "cd #{release_path}; compass -u"

  # Make sure all tests pass
  run "cd #{release_path}; rake db:test:prepare"
  run "cd #{release_path}; rake spec"
end

task :after_setup, :roles => :web do
  set_permissions
end

task :set_permissions do
  sudo "chown -R deploy:www-data #{deploy_to}"
  sudo "chmod -R g+w #{deploy_to}"
end
