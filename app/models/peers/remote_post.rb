module Peers
  class RemotePost
    attr_reader :slug, :title, :preview_text, :preview_image_urls, :created_at, :user, :hostname

    def initialize(attrs = {})
      @slug = attrs["slug"] || attrs[:slug]
      @title = attrs["title"] || attrs[:title]
      @preview_text = attrs["preview_text"] || attrs[:preview_text]
      @preview_image_urls = attrs["preview_image_urls"] || attrs[:preview_image_urls] || []
      @is_article = attrs["is_article"] || attrs[:is_article]
      @created_at = Time.parse(attrs["created_at"] || attrs[:created_at]) rescue nil
      @hostname = attrs["hostname"] || attrs[:hostname]

      user_attrs = attrs["user"] || attrs[:user] || {}
      @user = RemoteUser.new(user_attrs)
    end

    def article?
      @is_article
    end

    def to_param
      @slug
    end

    def url
      "https://#{@hostname}/posts/#{@slug}"
    end

    class RemoteUser
      attr_reader :name, :avatar_url

      def initialize(attrs = {})
        @name = attrs["name"] || attrs[:name]
        @avatar_url = attrs["avatar_url"] || attrs[:avatar_url]
      end
    end
  end
end
