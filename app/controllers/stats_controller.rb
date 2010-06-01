class StatsController < ApplicationController
  layout 'standard'
  before_filter :get_all_users, 
    :get_active_users, 
    :get_paying_users, 
    :get_plan_breakdown,
    :get_requests

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
      :chd => "t:#{@free_user_count},#{@plus_user_count},#{@power_user_count}",
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
end
