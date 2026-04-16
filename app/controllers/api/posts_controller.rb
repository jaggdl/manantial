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
      @post = Current.user.posts.build(post_params)

      if @post.save
        render json: PostSerializer.new(@post), status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      @post = Current.user.posts.find_by!(slug: params[:id])

      if @post.update(post_params)
        render json: PostSerializer.new(@post)
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Post not found" }, status: :not_found
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
      params.permit(:title, :body)
    end
  end
end
