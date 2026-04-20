module Peers
  class PostsController < PrivateBaseController
    def index
      posts = Current.owner.posts.order(created_at: :desc).limit(20).map do |post|
        {
          slug: post.slug,
          title: post.title,
          preview_text: post.preview_text,
          preview_image_urls: post.preview_images.map { |blob| url_for(blob) },
          is_article: post.article?,
          created_at: post.created_at.iso8601,
          user: {
            name: post.user.name,
            avatar_url: post.user.avatar.attached? ? url_for(post.user.avatar.variant(resize_to_limit: [128, 128])) : nil
          }
        }
      end

      render json: posts
    end
  end
end
