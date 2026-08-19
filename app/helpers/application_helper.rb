module ApplicationHelper
  def base_url
    ENV.fetch("BASE_URL", "https://manantial.jaggdl.com")
  end

  def owner_avatar_url
    return nil unless Current.owner&.avatar&.attached?

    url_for(Current.owner.avatar.variant(resize_to_fill: [64, 64]))
  end
end
