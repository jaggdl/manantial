class Api::V1::PostsController < ApplicationController
  include OriginDomainChecker

  before_action :set_post, only: [:show]

  def show
    render json: @post, serializer: PostSerializer
  end

  private

  def set_post
    @post = Post.visible_posts.friendly.find(params[:id])
  end
end
