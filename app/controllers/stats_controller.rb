class StatsController < ApplicationController
  layout 'standard'
  before_filter :get_all_users, :get_active_users, :get_paying_users

  def index
    chart_params = {
      :cht => 'lc',
      :chs => '600x300',
      :chbh => '2,2,4',
      :chxt => 'x,y',
      :chco => 'CFE0FF,76A4FB,005DFF',
      :chm => 'b,CFE0FF,0,1,0|b,76A4FB,1,2,0|B,005DFF,2,0,0',
      :chxl => "0:|#{@months.join('|')}",
      :chxr => "1,0,#{@max_users}",
      :chds => "0,#{@max_users}",
      :chd => "t:#{@all_users.join(',')}|#{@active_users.join(',')}|#{@paying_users.join(',')}",
      :chdl => 'All|Active|Paying'
    }
    @chart_url = "http://chart.apis.google.com/chart?#{chart_params.to_query}"
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
      ON j.date <= d.date AND j.date >= '2010-02-01'
      WHERE d.date >= '2010-02-01' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
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
      ON j.date <= d.date AND j.date >= '2010-02-01'
      WHERE d.date >= '2010-02-01' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
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
        WHERE u.subscription_level != 0
        GROUP BY date) j
      ON j.date <= d.date AND j.date >= '2010-02-01'
      WHERE d.date >= '2010-02-01' AND d.date <= '#{Time.now.strftime('%Y-%m-%d')}'
      GROUP BY d.date
    SQL
    )
    @paying_users = raw_data.collect { |x| x['users'].to_i }
  end
end
