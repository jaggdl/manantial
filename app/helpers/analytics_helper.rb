module AnalyticsHelper
  def time_period_options
    [['Last 30 days', '30'], ['Last 60 days', '60'], ['Last 90 days', '90']]
  end

  def group_period_options
    [['Per Day', 'day'], ['Per Week', 'week'], ['Per Month', 'month']]
  end
end
