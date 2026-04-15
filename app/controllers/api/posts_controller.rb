module Api
  class PostsController < BaseController
    def index
      @posts = Current.user.posts.order(created_at: :desc)
      render json: @posts.map { |post| serialize_post(post) }
    end

    def show
      @post = Current.user.posts.find_by!(slug: params[:id])
      render json: serialize_post(@post)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Post not found" }, status: :not_found
    end

    private

    def serialize_post(post)
      {
        id: post.id,
        title: post.title,
        slug: post.slug,
        content: post.body.to_plain_text,
        html_content: post.body.to_s,
        created_at: post.created_at,
        updated_at: post.updated_at
      }
    end
  end
end
