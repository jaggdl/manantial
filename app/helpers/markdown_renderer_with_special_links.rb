class MarkdownRendererWithSpecialLinks < Redcarpet::Render::HTML
  def preprocess(full_document)
    updated_document = full_document.gsub(/(^|\s)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(\s|$)/) do |match|
      prefix = ::Regexp.last_match(1)
      hostname = ::Regexp.last_match(2)
      suffix = ::Regexp.last_match(3)
      "#{prefix}#{hostname_link(hostname)}#{suffix}"
    end

    # Preprocess images to prepend the hostname
    updated_document.gsub(/!\[(.+?)\]\((.+?)\)/) do |match|
      alt_text = ::Regexp.last_match(1)
      image_url = ::Regexp.last_match(2)
      full_url = image_url.start_with?('/') ? "#{ENV['DOMAIN']}#{image_url}" : image_url
      "![#{alt_text}](#{full_url})"
    end
  end

  def autolink(link, link_type)
    case link_type
    when :url then url_link(link)
    when :email then email_link(link)
    end
  end

  def url_link(link)
    case link
    when /youtube\.com/
      youtube_link(link)
    else
      normal_link(link)
    end
  end

  def youtube_link(link)
    youtube_regex = %r{(?:youtube\.com/(?:[^/\n\s]+/\S*?/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([a-zA-Z0-9_-]{11})}
    video_id = link.match(youtube_regex)&.captures&.first

    if video_id
      render_partial('posts/youtube_iframe', video_id:)
    else
      'Invalid YouTube URL'
    end
  end

  def hostname_link(hostname)
    domain = "https://#{hostname}"
    connection = Connection::Set.find_by(domain: hostname)

    return render_chip(name: hostname, domain:) unless connection.present?

    if connection.public_info.present?
      render_chip(**connection.public_info.symbolize_keys, domain: connection.localized_domain_url)
    else
      render_chip(name: hostname, domain:)
    end
  end

  def render_chip(name:, domain:, profile_picture: nil)
    render_partial('profiles/chip', profile_picture:, name:, domain:)
  end

  def normal_link(link)
    "<a href=\"#{link}\">#{link}</a>"
  end

  def email_link(email)
    "<a href=\"mailto:#{email}\">#{email}</a>"
  end

  private

  def render_partial(partial, locals = {})
    ApplicationController.render(partial:, locals:)
  end
end
