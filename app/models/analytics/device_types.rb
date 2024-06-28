class Analytics::DeviceTypes < Analytics::Base
  private

  def group_query
    where_query
      .group(:device_type)
  end
end
