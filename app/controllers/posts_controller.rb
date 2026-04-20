class PostsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]

  def index
    if authenticated?
      @post_previews = build_post_previews
    else
      @post_previews = Current.owner.posts.order(created_at: :desc).map { |post| PostPreview.from_post(post, self) }
    end
  end

  def show
    @post = Post.find_by!(slug: params[:slug])
  end

  def new
    @post = Current.user.posts.build
  end

  def create
    @post = Current.user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @post = Current.user.posts.find_by!(slug: params[:slug])
  end

  def update
    @post = Current.user.posts.find_by!(slug: params[:slug])
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Current.user.posts.find_by!(slug: params[:slug])
    @post.destroy
    redirect_to posts_path, notice: "Post was successfully deleted."
  end

  private

  def build_post_previews
    local = Current.owner.posts.order(created_at: :desc).map { |post| PostPreview.from_post(post, self) }
    remote = Peers::Connection.active.flat_map(&:fetch_posts).map { |remote| PostPreview.from_remote(remote) }
    (local + remote).sort_by(&:created_at).reverse
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
