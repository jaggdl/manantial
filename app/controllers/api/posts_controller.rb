module Api
  class PostsController < BaseController
    def index
      @posts = Current.user.posts.order(created_at: :desc)
      render json: @posts.map { |post| PostSerializer.new(post).as_json }
    end

    def show
      @post = Current.user.posts.find_by!(slug: params[:id])
      render json: PostSerializer.new(@post)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Post not found" }, status: :not_found
    end

    def create
      @post = Post.create_from_markdown!(user: Current.user, **post_params)
      render json: PostSerializer.new(@post), status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    def update
      @post = Current.user.posts.find_by!(slug: params[:id])
      @post.update_from_markdown!(post_params)
      render json: PostSerializer.new(@post)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Post not found" }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    def destroy
      @post = Current.user.posts.find_by!(slug: params[:id])
      @post.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Post not found" }, status: :not_found
    end

    private

    def post_params
      params.permit(:title, :body).to_h.symbolize_keys
    end
  end
end
