module ApplicationHelper
  def base_url
    ENV.fetch("BASE_URL", "https://manantial.jaggdl.com")
  end
end
