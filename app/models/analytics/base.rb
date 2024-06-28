class Analytics::Base
  def initialize(range, group_period = nil)
    @range = range
    @group_period = group_period
  end

  def raw_data
    group_query
      .order('count_id DESC')
      .count(:id)
  end

  def formatted_data
    raw_data.map { |key, value| formatter(key, value) }
  end

  private

  def where_query
    Ahoy::Visit.where(started_at: @range)
  end

  def group_query
    where_query
  end

  def formatter(key, value)
    [format_key(key), format_value(value)]
  end

  def format_key(key)
    key
  end

  def format_value(value)
    value
  end
end
