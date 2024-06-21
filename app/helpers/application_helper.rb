module ApplicationHelper
  TIME_PERIODS = [
    { unit: "year",   seconds: 31_536_000 },
    { unit: "month",  seconds: 2_592_000 },
    { unit: "day",    seconds: 86_400 },
    { unit: "hour",   seconds: 3_600 },
    { unit: "minute", seconds: 60 },
    { unit: "second", seconds: 1 }
  ].freeze

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

  def active_link_to(name, path)
    if path == '/'
      class_name = request.path == '/' ? 'font-semibold' : ''
    else
      class_name = request.path.start_with?(path) ? 'font-semibold' : ''
    end
    link_to name, path, class: class_name
  end
end
