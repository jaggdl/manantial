class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    @visitors_per_day = Ahoy::Visit.group_by_day(:started_at).count
  end
end
