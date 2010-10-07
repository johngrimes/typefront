class CreateStatsViews < ActiveRecord::Migration
  TYPEFRONT_START_DATE = '2010-02-05'

  def self.up
    create_view :stats_unactivated_users_total, "
        SELECT d.date AS date, SUM(j.users_joined) AS users
        FROM dates d 
        LEFT OUTER JOIN 
          (SELECT date, COUNT(id) AS users_joined
          FROM dates LEFT OUTER JOIN users u 
            ON date = DATE(created_at)
            AND u.active = false
          GROUP BY date) j
        ON j.date <= d.date AND j.date >= '#{TYPEFRONT_START_DATE}'
        WHERE d.date >= current_date - interval '3 months' AND d.date <= current_date
        GROUP BY d.date
        " do |v|
      v.column :date
      v.column :users
    end

    create_view :stats_free_users_total, "
        SELECT d.date AS date, SUM(j.users_joined) AS users
        FROM dates d 
        LEFT OUTER JOIN 
          (SELECT date, COUNT(id) AS users_joined
          FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
            AND u.subscription_level = #{User::FREE}
            AND u.active = true
          GROUP BY date) j
        ON j.date <= d.date AND j.date >= '#{TYPEFRONT_START_DATE}'
        WHERE d.date >= current_date - interval '3 months' AND d.date <= current_date
        GROUP BY d.date
        " do |v|
      v.column :date
      v.column :users
    end

    create_view :stats_paying_users_total, "
        SELECT d.date AS date, SUM(j.users_joined) AS users
        FROM dates d 
        LEFT OUTER JOIN 
          (SELECT date, COUNT(id) AS users_joined
          FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
            AND u.subscription_level != #{User::FREE}
            AND u.active = true
          GROUP BY date) j
        ON j.date <= d.date AND j.date >= '#{TYPEFRONT_START_DATE}'
        WHERE d.date >= current_date - interval '3 months' AND d.date <= current_date
        GROUP BY d.date
        " do |v|
      v.column :date
      v.column :users
    end

    create_view :stats_free_users_joined, "
        SELECT date AS date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.active = true
          AND u.subscription_level = #{User::FREE}
        WHERE date >= current_date - interval '3 months' AND date <= current_date
        GROUP BY date
        " do |v|
      v.column :date
      v.column :users_joined
    end

    create_view :stats_plus_users_joined, "
        SELECT date AS date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.active = true
          AND u.subscription_level = #{User::PLUS}
        WHERE date >= current_date - interval '3 months' AND date <= current_date
        GROUP BY date
        " do |v|
      v.column :date
      v.column :users_joined
    end

    create_view :stats_power_users_joined, "
        SELECT date AS date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.active = true
          AND u.subscription_level = #{User::POWER}
        WHERE date >= current_date - interval '3 months' AND date <= current_date
        GROUP BY date
        " do |v|
      v.column :date
      v.column :users_joined
    end

    create_view :stats_plan_breakdown, "
        SELECT f.count AS free_users, p.count AS plus_users, pp.count AS power_users
        FROM (SELECT COUNT(*)
          FROM users
          WHERE subscription_level = #{User::FREE}
          AND active = true) f,
          (SELECT COUNT(*)
          FROM users
          WHERE subscription_level = #{User::PLUS}
          AND active = true) p,
          (SELECT COUNT(*)
          FROM users
          WHERE subscription_level = #{User::POWER}
          AND active = true) pp
        " do |v|
      v.column :free_users
      v.column :plus_users
      v.column :power_users
    end

    create_view :stats_requests, "
        SELECT date, COUNT(id) AS requests
        FROM dates LEFT OUTER JOIN logged_requests r ON date = DATE(created_at)
        WHERE date >= current_date - interval '3 months' AND date <= current_date
        GROUP BY date
        " do |v|
      v.column :date
      v.column :requests
    end

    create_view :stats_average_response_times, "
        SELECT date, AVG(response_time) AS response_time
        FROM dates LEFT OUTER JOIN logged_requests l ON date = DATE(created_at)
          AND l.format IN (#{Font::AVAILABLE_FORMATS.collect { |x| "'#{x}'" }.join(',')})
        WHERE date >= current_date - interval '3 months' AND date <= current_date
        GROUP BY date
        " do |v|
      v.column :date
      v.column :requests
    end

    create_view :stats_formats_breakdown, "
      SELECT ttf.count AS ttf_requests, otf.count AS otf_requests, eot.count AS eot_requests, woff.count AS woff_requests, svg.count AS svg_requests
      FROM (SELECT COUNT(*)
        FROM logged_requests
        WHERE format = 'ttf'
        AND DATE(created_at) >= current_date - interval '3 months' 
        AND DATE(created_at) <= current_date) ttf,
        (SELECT COUNT(*)
        FROM logged_requests
        WHERE format = 'otf'
        AND DATE(created_at) >= current_date - interval '3 months' 
        AND DATE(created_at) <= current_date) otf,
        (SELECT COUNT(*)
        FROM logged_requests
        WHERE format = 'eot'
        AND DATE(created_at) >= current_date - interval '3 months' 
        AND DATE(created_at) <= current_date) eot,
        (SELECT COUNT(*)
        FROM logged_requests
        WHERE format = 'woff'
        AND DATE(created_at) >= current_date - interval '3 months' 
        AND DATE(created_at) <= current_date) woff,
        (SELECT COUNT(*)
        FROM logged_requests
        WHERE format = 'svg'
        AND DATE(created_at) >= current_date - interval '3 months' 
        AND DATE(created_at) <= current_date) svg
        " do |v|
      v.column :ttf_requests
      v.column :otf_requests
      v.column :eot_requests
      v.column :woff_requests
      v.column :svg_requests
    end
  end

  def self.down
    drop_view :stats_unactivated_users_total
    drop_view :stats_free_users_total
    drop_view :stats_paying_users_total
    drop_view :stats_free_users_joined
    drop_view :stats_plus_users_joined
    drop_view :stats_power_users_joined
    drop_view :stats_plan_breakdown
    drop_view :stats_requests
    drop_view :stats_average_response_times
    drop_view :stats_formats_breakdown
  end
end
