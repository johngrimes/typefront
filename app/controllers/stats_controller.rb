class StatsController < ApplicationController
  layout 'standard'

  def index
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
    aggregate_users_joined = raw_data.collect { |x| x['users'] }
    max_users_in_one_day = aggregate_users_joined.max.to_i
    months = []
    raw_data.each do |x|
      month = Date.strptime(x['date'], '%Y-%m-%d').strftime('%B')
      unless months.include?(month)
        months.push(month)
      end
    end
    chart_params = {
      :cht => 'lc',
      :chs => '600x300',
      :chbh => '2,2,4',
      :chxt => 'x,y',
      :chxl => "0:|#{months.join('|')}",
      :chxr => "1,0,#{max_users_in_one_day}",
      :chds => "0,#{max_users_in_one_day}",
      :chd => "t:#{aggregate_users_joined.join(',')}"
    }
    @chart_url = "http://chart.apis.google.com/chart?#{chart_params.to_query}"
  end
end
