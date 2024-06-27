SitemapGenerator::Sitemap.default_host = ENV['DOMAIN']

SitemapGenerator::Sitemap.create do
  I18n.available_locales.each do |locale|
    if locale == I18n.default_locale
      add posts_path, priority: 0.7, changefreq: 'daily'
      Post.find_each do |post|
        add post_path(post, locale: nil), :lastmod => post.updated_at
      end
    else
      add posts_path(locale: locale), priority: 0.7, changefreq: 'daily'
      Post.find_each do |post|
        add post_path(post, locale: locale), :lastmod => post.updated_at
      end
    end
  end
end
