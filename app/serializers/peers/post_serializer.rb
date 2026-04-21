module Peers
  class PostSerializer
    include ActiveModel::Serializers::JSON

    def initialize(post, view_context)
      @post = post
      @view_context = view_context
    end

    def attributes
      {
        "slug" => nil,
        "title" => nil,
        "preview_text" => nil,
        "preview_image_urls" => nil,
        "is_article" => nil,
        "created_at" => nil,
        "user" => nil
      }
    end

    def slug
      @post.slug
    end

    def title
      @post.title
    end

    def preview_text
      @post.preview_text
    end

    def preview_image_urls
      @post.preview_images.map { |blob| @view_context.url_for(blob.representation(resize_to_limit: [800, 800])) }
    end

    def is_article
      @post.article?
    end

    def created_at
      @post.created_at.iso8601
    end

    def user
      ProfileSerializer.new(@post.user, @view_context).as_json
    end
  end
end
