class Analytics::ReferringDomains < Analytics::Base
  private

  def group_query
    where_query.group(:referring_domain)
  end

  def format_key(key)
    uri = URI(ENV['DOMAIN'])
    return nil unless key.present?
    return 'Direct' if key.include?(uri.host)
    key
  end
end
