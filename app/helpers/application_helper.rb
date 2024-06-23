module ApplicationHelper
  TIME_PERIODS = [
    { unit: "year",   seconds: 31_536_000 },
    { unit: "month",  seconds: 2_592_000 },
    { unit: "day",    seconds: 86_400 },
    { unit: "hour",   seconds: 3_600 },
    { unit: "minute", seconds: 60 },
    { unit: "second", seconds: 1 }
  ].freeze

  LOCALES_WITH_TERRITORY = {
    :en => 'en_US',
    :es => 'es_MX',
  }.freeze

  def time_since_created(created_at)
    time_difference = Time.now - created_at

    TIME_PERIODS.each do |period|
      if time_difference >= period[:seconds]
        value = (time_difference / period[:seconds]).to_i
        unit = value == 1 ? period[:unit] : period[:unit] + 's'
        return "#{value} #{unit} ago"
      end
    end

    "just now"
  end

  def locale_with_territory(locale = nil)
    LOCALES_WITH_TERRITORY[locale || I18n.locale]
  end
end
