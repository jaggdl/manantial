class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :track_ahoy_visit

  def index
    time_period = params[:time_period].to_i
    time_period = 30 if time_period.zero? # Default to 30 days if not provided

    group_period = params[:group_period] || 'day'
    @start_date = time_period.days.ago.to_date
    @end_date = Date.current

    @visitors = Analytics::Visitors.new(range: @start_date..@end_date, group_period: group_period)

    @analytics_data = [
      :referring_domains,
      :landing_pages,
      :countries,
      :cities,
      :device_types,
    ].map{|hash| [hash, get_formatted_data(hash)] }.to_h
  end

  private

  def get_formatted_data(hash)
    classname = "Analytics::#{hash.to_s.camelize}"
    group = Object.const_get(classname).new(
      range: @start_date..@end_date,
      group_limit: 6
    )
    group.formatted_data
  end
end
