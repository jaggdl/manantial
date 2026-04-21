module Peers
  class PostsController < PrivateBaseController
    def index
      posts = Current.owner.posts.order(created_at: :desc).limit(20).map do |post|
        PostSerializer.new(post, self).as_json
      end

      render json: posts
    end
  end
end
