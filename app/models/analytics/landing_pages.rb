class Analytics::LandingPages < Analytics::Base
  private

  def group_query
    where_query.group(:landing_page)
  end

  def format_key(key)
    begin
      uri = URI(key)
      path_with_query = uri.path
      path_with_query += "?#{uri.query}" if uri.query
      path_with_query
    rescue
      nil
    end
  end
end
