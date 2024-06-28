class Analytics::ReferringDomains < Analytics::Base
  private

  def group_query
    where_query.group(:referring_domain)
  end
end
