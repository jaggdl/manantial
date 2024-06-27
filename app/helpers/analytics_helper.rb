module AnalyticsHelper
  def time_period_options
    [
      ['Today', '1'],
      ['Last 7 days', '7'],
      ['Last 30 days', '30'],
      ['Last 60 days', '60'],
      ['Last 90 days', '90']
    ]
  end

  def group_period_options
    [
      ['Per Hour', 'hour'],
      ['Per Day', 'day'],
      ['Per Week', 'week'],
      ['Per Month', 'month']
    ]
  end
end
