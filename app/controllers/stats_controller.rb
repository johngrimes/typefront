class StatsController < ApplicationController
  layout 'standard'
  before_filter :get_all_users, 
    :get_active_users, 
    :get_paying_users, 
    :get_plan_breakdown,
    :get_requests,
    :get_average_response_times,
    :get_formats_breakdown

  TYPEFRONT_LAUNCH_DATE = '2010-02-05'
  REPORT_START_DATE = (Time.now - 3.months).strftime('%Y-%m-%d')

  def index
    total_users_params = {
      :cht => 'lc',
      :chs => '600x300',
      :chxt => 'x,y',
      :chco => 'CFE0FF,76A4FB,005DFF',
      :chm => 'b,CFE0FF,0,1,0|b,76A4FB,1,2,0|B,005DFF,2,0,0',
      :chxl => "0:|#{@months.join('|')}",
      :chxr => "1,0,#{@max_users}",
      :chds => "0,#{@max_users}",
      :chd => "t:#{@all_users.join(',')}|#{@active_users.join(',')}|#{@paying_users.join(',')}",
      :chdl => 'All|Active|Paying'
    }
    @total_users_url = "http://chart.apis.google.com/chart?#{total_users_params.to_query}"

    plan_breakdown_params = {
      :cht => 'p',
      :chs => '600x300',
      :chco => '76A4FB,005DFF,0000CC',
      :chl => "Free (#{@free_user_count})|Plus (#{@plus_user_count})|Power (#{@power_user_count})",
      :chd => "t:#{@free_user_count},#{@plus_user_count},#{@power_user_count}"
    }
    @plan_breakdown_url = "http://chart.apis.google.com/chart?#{plan_breakdown_params.to_query}"

    requests_params = {
      :cht => 'lc',
      :chs => '600x300',
      :chxt => 'x,y',
      :chco => '76A4FB',
      :chxl => "0:|#{@months.join('|')}",
      :chxr => "1,0,#{@max_requests}",
      :chds => "0,#{@max_requests}",
      :chd => "t:#{@requests.join(',')}",
    }
    @requests_url = "http://chart.apis.google.com/chart?#{requests_params.to_query}"

    response_time_params = {
      :cht => 'lc',
      :chs => '600x300',
      :chxt => 'x,y',
      :chco => '76A4FB',
      :chxl => "0:|#{@months.join('|')}",
      :chxr => "1,0,#{@max_response_time}",
      :chds => "0,#{@max_response_time}",
      :chd => "t:#{@response_times.join(',')}",
    }
    @response_times_url = "http://chart.apis.google.com/chart?#{response_time_params.to_query}"

    formats_breakdown_params = {
      :cht => 'p',
      :chs => '600x300',
      :chco => 'FEF6E2,74C6F1,820F00,FF4A12,ABC507',
      :chl => "TrueType (#{@ttf_request_count})|OpenType (#{@otf_request_count})|EOT (#{@eot_request_count})|WOFF (#{@woff_request_count})|SVG (#{@svg_request_count})",
      :chd => "t:#{@ttf_request_count},#{@otf_request_count},#{@eot_request_count},#{@woff_request_count},#{@svg_request_count}"
    }
    @formats_breakdown_url = "http://chart.apis.google.com/chart?#{formats_breakdown_params.to_query}"
  end

  private

  def get_all_users
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT d.date, SUM(j.users_joined) AS users
      FROM dates d 
      LEFT OUTER JOIN 
        (SELECT date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '#{TYPEFRONT_LAUNCH_DATE}'
      WHERE d.date >= '#{REPORT_START_DATE}' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @all_users = raw_data.collect { |x| x['users'].to_i }
    @max_users = @all_users.max
    @months = []
    raw_data.each do |x|
      month = Date.strptime(x['date'], '%Y-%m-%d').strftime('%B')
      unless @months.include?(month)
        @months.push(month)
      end
    end
  end

  def get_active_users
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT d.date, SUM(j.users_joined) AS users
      FROM dates d 
      LEFT OUTER JOIN 
        (SELECT date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
        WHERE u.active = 1
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '#{TYPEFRONT_LAUNCH_DATE}'
      WHERE d.date >= '#{REPORT_START_DATE}' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @active_users = raw_data.collect { |x| x['users'].to_i }
  end

  def get_paying_users
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT d.date, SUM(j.users_joined) AS users
      FROM dates d 
      LEFT OUTER JOIN 
        (SELECT date, COUNT(id) AS users_joined
        FROM dates LEFT OUTER JOIN users u ON date = DATE(created_at)
        WHERE u.subscription_level != #{User::FREE}
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '#{TYPEFRONT_LAUNCH_DATE}'
      WHERE d.date >= '#{REPORT_START_DATE}' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @paying_users = raw_data.collect { |x| x['users'].to_i }
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
    @max_requests = @requests.max
  end

  def get_average_response_times
    raw_data = User.connection.select_all(
    <<-SQL
      SELECT date, AVG(response_time) AS response_time
      FROM dates LEFT OUTER JOIN logged_requests l ON date = DATE(created_at)
      WHERE l.format IN (#{Font::AVAILABLE_FORMATS.collect { |x| '"#{x}"' }.join(',')})
      AND date >= '#{REPORT_START_DATE}' AND date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY date
    SQL
    )
    @response_times = raw_data.collect { |x| x['response_time'].to_f }
    @max_response_time = @response_times.max
  end

  def get_formats_breakdown
    @ttf_request_count = LoggedRequest.count(
      :conditions => ['format = "ttf" 
        AND created_at >= ? AND created_at <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @otf_request_count = LoggedRequest.count(
      :conditions => ['format = "otf" 
        AND created_at >= ? AND created_at <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @eot_request_count = LoggedRequest.count(
      :conditions => ['format = "eot" 
        AND created_at >= ? AND created_at <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @woff_request_count = LoggedRequest.count(
      :conditions => ['format = "woff" 
        AND created_at >= ? AND created_at <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
    @svg_request_count = LoggedRequest.count(
      :conditions => ['format = "svg" 
        AND created_at >= ? AND created_at <= ?', 
        REPORT_START_DATE, Time.now.strftime('%Y-%m-%d')])
  end
end
