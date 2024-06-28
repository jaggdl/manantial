class Analytics::Countries < Analytics::Base
  private

  def group_query
    where_query
      .group(:country)
  end

  def format_key(key)
    return key unless key.present?

    I18n.t("countries.#{key}")
  end
end
