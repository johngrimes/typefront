class StatsController < ApplicationController
  layout 'standard'
  before_filter :get_stats

  TYPEFRONT_LAUNCH_DATE = '2010-02-05'
  REPORT_START_DATE = (Time.now - 3.months).strftime('%Y-%m-%d')

  def index
  end

  private

  def get_stats
    user_totals = User.connection.select_all('SELECT * FROM mv_stats_users_total ORDER BY date')
    @unactivated_users_total = user_totals.collect {|x| x['inactive'] }
    @free_users_total = user_totals.collect {|x| x['free'] }
    @paying_users_total = user_totals.collect {|x| x['paying'] }

    users_joined = User.connection.select_all('SELECT * FROM mv_stats_users_joined ORDER BY date')
    @free_users_joined = users_joined.collect {|x| x['free'] }
    @plus_users_joined = users_joined.collect {|x| x['plus'] }
    @power_users_joined = users_joined.collect {|x| x['power'] }

    user_counts = User.connection.select_all('SELECT * FROM mv_stats_plan_breakdown').first
    @free_user_count = user_counts['free']
    @plus_user_count = user_counts['plus']
    @power_user_count = user_counts['power']

    request_info = User.connection.select_all('SELECT * FROM mv_stats_requests ORDER BY date')
    @requests = request_info.collect {|x| x['requests'] }
    @response_times = request_info.collect {|x| x['response_time'] }

    format_counts = User.connection.select_all('SELECT * FROM mv_stats_formats_breakdown').first
    @ttf_request_count = format_counts['ttf']
    @otf_request_count= format_counts['otf']
    @eot_request_count = format_counts['eot']
    @woff_request_count = format_counts['woff']
    @svg_request_count = format_counts['svg']
  end
end
