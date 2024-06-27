class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    time_period = params[:time_period].to_i
    group_period = params[:group_period] || 'day'
    time_period = 30 if time_period.zero? # Default to 30 days if not provided

    start_date = time_period.days.ago.to_date
    end_date = Date.current

    @visitors_data = fetch_visitors_data(start_date, end_date, group_period)
  end

  private

  def fetch_visitors_data(start_date, end_date, group_period)
    Ahoy::Visit.where(started_at: start_date..end_date)
               .public_send("group_by_#{group_period}", :started_at, range: start_date..end_date)
               .count
  end
end
