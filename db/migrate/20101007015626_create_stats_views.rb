class CreateStatsViews < ActiveRecord::Migration
  TYPEFRONT_START_DATE = '2010-02-05'

  def self.up
    create_view :stats_users_total, "
      SELECT inactive.date AS date, 
        inactive.users AS inactive, 
        free.users AS free, 
        paying.users AS paying

      FROM
        (SELECT d.date AS date, SUM(j.users_joined) AS users
        FROM dates d 
        LEFT OUTER JOIN 
          (SELECT date, COUNT(id) AS users_joined
          FROM dates LEFT OUTER JOIN users u 
            ON date = DATE(created_at)
            AND u.active = false
          GROUP BY date) j
        ON j.date <= d.date AND j.date >= '#{TYPEFRONT_START_DATE}'
        WHERE d.date >= current_date - interval '3 months' AND d.date <= current_date
        GROUP BY d.date) inactive INNER JOIN
        
        (SELECT d.date AS date, SUM(j.users_joined) AS users
        FROM dates d 
        LEFT OUTER JOIN 
          (SELECT date, COUNT(id) AS users_joined
          FROM dates LEFT OUTER JOIN users u 
            ON date = DATE(created_at)
            AND u.active = true
            AND u.subscription_level = #{User::FREE}
          GROUP BY date) j
        ON j.date <= d.date AND j.date >= '#{TYPEFRONT_START_DATE}'
        WHERE d.date >= current_date - interval '3 months' AND d.date <= current_date
        GROUP BY d.date) free ON inactive.date = free.date INNER JOIN
        
        (SELECT d.date AS date, SUM(j.users_joined) AS users
        FROM dates d 
        LEFT OUTER JOIN 
          (SELECT date, COUNT(id) AS users_joined
          FROM dates LEFT OUTER JOIN users u 
            ON date = DATE(created_at)
            AND u.active = true
            AND u.subscription_level != #{User::FREE}
          GROUP BY date) j
        ON j.date <= d.date AND j.date >= '#{TYPEFRONT_START_DATE}'
        WHERE d.date >= current_date - interval '3 months' AND d.date <= current_date
        GROUP BY d.date) paying ON inactive.date = paying.date
        " do |v|
      v.column :date
      v.column :inactive
      v.column :free
      v.column :paying
    end

    create_view :stats_users_joined, "
      SELECT free.date,
        free.users_joined AS free,
        plus.users_joined AS plus,
        power.users_joined AS power

      FROM
	(SELECT date AS date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.active = true
          AND u.subscription_level = #{User::FREE}
        WHERE date >= current_date - interval '3 months' AND date < current_date
        GROUP BY date) free INNER JOIN

        (SELECT date AS date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.active = true
          AND u.subscription_level = #{User::PLUS}
        WHERE date >= current_date - interval '3 months' AND date < current_date
        GROUP BY date) plus ON free.date = plus.date INNER JOIN

        (SELECT date AS date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.active = true
          AND u.subscription_level = #{User::POWER}
        WHERE date >= current_date - interval '3 months' AND date < current_date
        GROUP BY date) power ON free.date = power.date
        " do |v|
      v.column :date
      v.column :free
      v.column :plus
      v.column :power
    end

    create_view :stats_plan_breakdown, "
        SELECT f.count AS free, 
          p.count AS plus, 
          pp.count AS power
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
      v.column :free
      v.column :plus
      v.column :power
    end

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

    create_view :stats_formats_breakdown, "
      SELECT ttf.count AS ttf, 
        otf.count AS otf, 
        eot.count AS eot, 
        woff.count AS woff, 
        svg.count AS svg
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
      v.column :ttf
      v.column :otf
      v.column :eot
      v.column :woff
      v.column :svg
    end
  end

  def self.down
    drop_view :stats_users_total
    drop_view :stats_users_joined
    drop_view :stats_plan_breakdown
    drop_view :stats_requests
    drop_view :stats_formats_breakdown
  end
end
