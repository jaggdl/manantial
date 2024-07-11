class Api::V1::PrivateController < ActionController::Base
  include OriginDomainChecker

  def latest_posts
    posts = Post.last(5)

    render json: posts, each_serializer: PostPreviewSerializer
  end
end
