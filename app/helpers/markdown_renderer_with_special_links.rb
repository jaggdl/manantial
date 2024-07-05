class MarkdownRendererWithSpecialLinks < Redcarpet::Render::HTML
  def preprocess(full_document)
    updated_document = full_document.gsub(/(^|\s)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(\s|$)/) do |match|
      prefix, hostname, suffix = $1, $2, $3
      "#{prefix}#{hostname_link(hostname)}#{suffix}"
    end
    updated_document
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
    youtube_regex = /(?:youtube\.com\/(?:[^\/\n\s]+\/\S*?\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
    video_id = link.match(youtube_regex)&.captures&.first

    if video_id
      render_partial('posts/youtube_iframe', video_id: video_id)
    else
      "Invalid YouTube URL"
    end
  end

  def hostname_link(hostname)

    connection = Connection::Set.find_by(domain: hostname)

    unless connection.present?
      return render_chip(nil, hostname)
    end

    response = HTTParty.get("https://#{hostname}/api/v1/connection/public_info")
    if response.success?
      data = response.parsed_response
      profile_picture = data['profile_picture']
      name = data['name']
      render_chip(profile_picture, name)
    else
      "Invalid hostname or failed to fetch data"
    end
  rescue StandardError => e
    "Error fetching data: #{e.message}"
  end

  def render_chip(profile_picture, name)
    render_partial('profiles/chip', profile_picture:, name:)
  end

  def normal_link(link)
    "<a href=\"#{link}\">#{link}</a>"
  end

  def email_link(email)
    "<a href=\"mailto:#{email}\">#{email}</a>"
  end

  private

  def render_partial(partial, locals = {})
    ApplicationController.render(partial: partial, locals: locals)
  end
end
