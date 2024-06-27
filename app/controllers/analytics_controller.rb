class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    time_period = params[:time_period].to_i
    group_period = params[:group_period] || 'day'
    time_period = 30 if time_period.zero? # Default to 30 days if not provided

    start_date = time_period.days.ago.to_date
    end_date = Date.current

    @visitors_data = case group_period
                     when 'week'
                       Ahoy::Visit.where(started_at: start_date..end_date)
                                  .group_by_week(:started_at, range: start_date..end_date)
                                  .count
                     when 'month'
                       Ahoy::Visit.where(started_at: start_date..end_date)
                                  .group_by_month(:started_at, range: start_date..end_date)
                                  .count
                     else
                       Ahoy::Visit.where(started_at: start_date..end_date)
                                  .group_by_day(:started_at, range: start_date..end_date)
                                  .count
                     end
  end
end
