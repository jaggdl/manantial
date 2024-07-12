module ApplicationHelper
  TIME_PERIODS = [
    { unit: :year,   seconds: 31_536_000 },
    { unit: :month,  seconds: 2_592_000 },
    { unit: :day,    seconds: 86_400 },
    { unit: :hour,   seconds: 3_600 },
    { unit: :minute, seconds: 60 },
    { unit: :second, seconds: 1 }
  ].freeze

  def time_since_created(created_at)
    created_at = Time.parse(created_at) if created_at.is_a?(String)

    time_difference = Time.now - created_at

    I18n.with_locale(I18n.locale) do
      TIME_PERIODS.each do |period|
        if time_difference >= period[:seconds]
          value = (time_difference / period[:seconds]).to_i
          unit_key = value == 1 ? period[:unit] : "#{period[:unit]}s".to_sym
          unit = I18n.t("time_periods.#{unit_key}")
          return I18n.t('time_since.ago', value: value, unit: unit)
        end
      end

      I18n.t('time_since.just_now')
    end
  end

  LOCALES_WITH_TERRITORY = {
    :en => 'en_US',
    :es => 'es_MX',
  }.freeze

  def locale_with_territory(locale = nil)
    LOCALES_WITH_TERRITORY[locale || I18n.locale]
  end

  def active_class(path)
    current_path = request.path
    is_root = current_path == root_path || current_path == "/es"

    if path == root_path
      return "font-semibold" if is_root
    else
      return "font-semibold" if current_path.start_with?(path)
    end

    ""
  end

  def owner_profile
    @owner_profile ||= Profile.last
  end
end
