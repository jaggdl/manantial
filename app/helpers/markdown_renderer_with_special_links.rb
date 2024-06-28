class MarkdownRendererWithSpecialLinks < Redcarpet::Render::HTML
  def autolink(link, link_type)
    case link_type
      when :url then url_link(link)
      when :email then email_link(link)
    end
  end

  def url_link(link)
    puts "url_link LINK: #{link} #{link.include?('youtube.com')}"

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
