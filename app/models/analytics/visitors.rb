class Analytics::Visitors < Analytics::Base
  private

  def group_query
    where_query
      .public_send("group_by_#{@group_period}", :started_at)
  end
end
