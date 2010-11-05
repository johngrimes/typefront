class RestoreRequestStatsView < ActiveRecord::Migration
  def self.up
    drop_view :stats_requests
    create_view :stats_requests, "
      SELECT requests.date AS date,
        requests.requests AS requests,
        response.response_time AS response_time

      FROM
	(SELECT date, COUNT(id) AS requests
        FROM dates LEFT OUTER JOIN logged_requests r ON date = DATE(created_at)
        WHERE date >= current_date - interval '3 months' AND date < current_date
        GROUP BY date) requests INNER JOIN

        (SELECT date, ROUND(AVG(response_time) * 1000) AS response_time
        FROM dates LEFT OUTER JOIN logged_requests l ON date = DATE(created_at)
          AND l.format IN (#{Font::AVAILABLE_FORMATS.collect { |x| "'#{x}'" }.join(',')})
        WHERE date >= current_date - interval '3 months' AND date < current_date
        GROUP BY date) response ON requests.date = response.date
        " do |v|
      v.column :date
      v.column :requests
      v.column :response_time
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
