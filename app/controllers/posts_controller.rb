class PostsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]

  before_action :set_post, only: [ :show ]
  before_action :set_owner_post, only: [ :edit, :update, :destroy, :pin, :unpin ]

  def index
    @post_previews = authenticated? ? PostPreview.federated(Current.owner, self) : PostPreview.for_owner(Current.owner, self)
  end

  def show
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
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post was successfully deleted."
  end

  def pin
    @post.pin!
    redirect_to @post, notice: "Post pinned."
  end

  def unpin
    @post.unpin!
    redirect_to @post, notice: "Post unpinned."
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  end

  def set_owner_post
    @post = Current.user.posts.find_by!(slug: params[:slug])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
