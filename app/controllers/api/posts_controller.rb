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

    def create
      @post = Current.user.posts.build(post_params)

      if @post.save
        render json: serialize_post(@post), status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      @post = Current.user.posts.find_by!(slug: params[:id])

      if @post.update(post_params)
        render json: serialize_post(@post)
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
