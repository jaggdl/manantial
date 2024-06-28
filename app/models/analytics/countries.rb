class Analytics::Countries < Analytics::Base
  private

  def group_query
    where_query
      .group(:country)
  end
end
