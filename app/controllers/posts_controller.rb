class PostsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]

  def index
    if authenticated?
      @posts = build_federated_feed
    else
      @posts = Current.owner.posts.order(created_at: :desc)
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

  def build_federated_feed
    local_posts = Current.owner.posts.order(created_at: :desc).to_a
    remote_posts = Peers::Connection.active.flat_map(&:fetch_posts)

    (local_posts + remote_posts).sort_by do |post|
      post.respond_to?(:created_at) ? post.created_at : Time.current
    end.reverse
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
