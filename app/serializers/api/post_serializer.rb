module Api
  class PostSerializer
    include ActiveModel::Serializers::JSON

    def initialize(post)
      @post = post
    end

    def attributes
      {
        "id" => nil,
        "title" => nil,
        "slug" => nil,
        "body" => nil,
        "body_html" => nil,
        "created_at" => nil,
        "updated_at" => nil
      }
    end

    def id
      @post.id
    end

    def title
      @post.title
    end

    def slug
      @post.slug
    end

    def body
      @post.body.to_plain_text
    end

    def body_html
      @post.body.to_s
    end

    def created_at
      @post.created_at.iso8601
    end

    def updated_at
      @post.updated_at.iso8601
    end
  end
end
