class Analytics::Cities < Analytics::Base
  private

  def group_query
    where_query
      .group(:city)
  end
end
