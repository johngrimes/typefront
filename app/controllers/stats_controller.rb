class StatsController < ApplicationController
  layout 'standard'
  before_filter :get_unactivated_users_total, 
    :get_free_users_total, 
    :get_paying_users_total, 
    :get_free_users_joined,
    :get_plus_users_joined,
    :get_power_users_joined,
    :get_plan_breakdown,
    :get_requests,
    :get_average_response_times,
    :get_formats_breakdown

  TYPEFRONT_LAUNCH_DATE = '2010-02-05'
  REPORT_START_DATE = (Time.now - 3.months).strftime('%Y-%m-%d')

  def index
  end

  private

  def get_unactivated_users_total
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT d.date, SUM(j.users_joined) AS users
      FROM dates d 
      LEFT OUTER JOIN 
        (SELECT date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u 
          ON date = DATE(created_at)
          AND u.active = 0
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '#{TYPEFRONT_LAUNCH_DATE}'
      WHERE d.date >= '#{REPORT_START_DATE}' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @unactivated_users_total = raw_data.collect { |x| x['users'].to_i }
  end

  def get_free_users_total
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT d.date, SUM(j.users_joined) AS users
      FROM dates d 
      LEFT OUTER JOIN 
        (SELECT date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.subscription_level = #{User::FREE}
          AND u.active = 1
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '#{TYPEFRONT_LAUNCH_DATE}'
      WHERE d.date >= '#{REPORT_START_DATE}' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @free_users_total = raw_data.collect { |x| x['users'].to_i }
  end

  def get_paying_users_total
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT d.date, SUM(j.users_joined) AS users
      FROM dates d 
      LEFT OUTER JOIN 
        (SELECT date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
          AND u.subscription_level != #{User::FREE}
          AND u.active = 1
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '#{TYPEFRONT_LAUNCH_DATE}'
      WHERE d.date >= '#{REPORT_START_DATE}' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @paying_users_total = raw_data.collect { |x| x['users'].to_i }
  end

  def get_free_users_joined
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT date, COUNT(id) AS users_joined
      FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
        AND u.active = 1
        AND u.subscription_level = #{User::FREE}
      WHERE date >= '#{REPORT_START_DATE}' AND date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY date
    SQL
    )
    @free_users_joined = raw_data.collect { |x| x['users_joined'].to_i }
  end

  def get_plus_users_joined
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT date, COUNT(id) AS users_joined
      FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
        AND u.active = 1
        AND u.subscription_level = #{User::PLUS}
      WHERE date >= '#{REPORT_START_DATE}' AND date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY date
    SQL
    )
    @plus_users_joined = raw_data.collect { |x| x['users_joined'].to_i }
  end

  def get_power_users_joined
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT date, COUNT(id) AS users_joined
      FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
        AND u.active = 1
        AND u.subscription_level = #{User::POWER}
      WHERE date >= '#{REPORT_START_DATE}' AND date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY date
    SQL
    )
    @power_users_joined = raw_data.collect { |x| x['users_joined'].to_i }
  end

  def get_plan_breakdown
    @free_user_count = User.count(:conditions => ['subscription_level = ? AND active = 1', User::FREE])
    @plus_user_count = User.count(:conditions => ['subscription_level = ? AND active = 1', User::PLUS])
    @power_user_count = User.count(:conditions => ['subscription_level = ? AND active = 1', User::POWER])
  end

  def get_requests
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT date, COUNT(id) AS requests
      FROM dates LEFT OUTER JOIN logged_requests r ON date = DATE(created_at)
      WHERE date >= '#{REPORT_START_DATE}' AND date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY date
    SQL
    )
    @requests = raw_data.collect { |x| x['requests'].to_i }
  end

  def get_average_response_times
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT date, AVG(response_time) AS response_time
      FROM dates LEFT OUTER JOIN logged_requests l ON date = DATE(created_at)
        AND l.format IN (#{Font::AVAILABLE_FORMATS.collect { |x| "\"#{x}\"" }.join(',')})
      WHERE date >= '#{REPORT_START_DATE}' AND date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY date
    SQL
    )
    @response_times = raw_data.collect { |x| (x['response_time'].to_f * 1000).to_i }
  end

  def get_formats_breakdown
    @ttf_request_count = LoggedRequest.count(
      :conditions => ['format = "ttf" 
        AND created_at >= ? AND DATE(created_at) <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @otf_request_count = LoggedRequest.count(
      :conditions => ['format = "otf" 
        AND created_at >= ? AND DATE(created_at) <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @eot_request_count = LoggedRequest.count(
      :conditions => ['format = "eot" 
        AND created_at >= ? AND DATE(created_at) <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @woff_request_count = LoggedRequest.count(
      :conditions => ['format = "woff" 
        AND created_at >= ? AND DATE(created_at) <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @svg_request_count = LoggedRequest.count(
      :conditions => ['format = "svg" 
        AND created_at >= ? AND DATE(created_at) <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
  end
end
