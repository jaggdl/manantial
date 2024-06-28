class Analytics::LandingPages < Analytics::Base
  private

  def group_query
    where_query.group(:landing_page)
  end

  def format_key(key)
    begin
      uri = URI(key)
      uri.path
    rescue
      nil
    end
  end
end
