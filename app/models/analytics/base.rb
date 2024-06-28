class Analytics::Base
  def initialize(range:, group_period: nil, group_limit: nil)
    @range = range
    @group_period = group_period
    @group_limit = group_limit
  end

  def raw_data
    group_query
      .order('count_id DESC')
      .count(:id)
  end

  def formatted_data
    accumulated_data = Hash.new(0)

    raw_data.each do |key, value|
      formatted_key = format_key(key)
      accumulated_data[formatted_key] += value
    end

    limited_data = accumulated_data.sort_by { |_, value| -value }
    limited_data = limited_data.take(@group_limit) if @group_limit

    limited_data.map { |formatted_key, total_value| [formatted_key, total_value] }
  end

  private

  def where_query
    Ahoy::Visit.where(started_at: @range)
  end

  def group_query
    where_query
  end

  def format_key(key)
    key
  end

  def format_value(value)
    value
  end
end
