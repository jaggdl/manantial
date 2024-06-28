class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    time_period = params[:time_period].to_i
    group_period = params[:group_period] || 'day'
    time_period = 30 if time_period.zero? # Default to 30 days if not provided

    start_date = time_period.days.ago.to_date
    end_date = Date.current

    @visitors_data = fetch_visitors_data(start_date, end_date, group_period)
    @top_countries = fetch_top_countries(start_date, end_date)
    @top_cities = fetch_top_cities(start_date, end_date)
    @top_device_types = fetch_top_device_types(start_date, end_date)
  end

  private

  def fetch_visitors_data(start_date, end_date, group_period)
    Ahoy::Visit.where(started_at: start_date..end_date)
               .public_send("group_by_#{group_period}", :started_at)
               .count
  end

  def fetch_top_countries(start_date, end_date)
    Ahoy::Visit.where(started_at: start_date..end_date)
               .group(:country)
               .order('count_id DESC')
               .count(:id)
  end

  def fetch_top_cities(start_date, end_date)
    Ahoy::Visit.where(started_at: start_date..end_date)
               .group(:city)
               .order('count_id DESC')
               .count(:id)
  end

  def fetch_top_device_types(start_date, end_date)
    Ahoy::Visit.where(started_at: start_date..end_date)
               .group(:device_type)
               .order('count_id DESC')
               .count(:id)
  end
end
