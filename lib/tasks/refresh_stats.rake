namespace :stats do
  desc 'Refreshes materialised views for statistics'
  task :refresh => :environment do
    stats_tables = %w{users_total users_joined plan_breakdown requests formats_breakdown}
    stats_tables.each do |table_name|
      User.connection.execute "DROP TABLE IF EXISTS mv_stats_#{table_name}"
      User.connection.execute "CREATE TABLE mv_stats_#{table_name} AS SELECT * FROM stats_#{table_name}"
    end
    User.connection.execute 'VACUUM ANALYZE'
  end
end
