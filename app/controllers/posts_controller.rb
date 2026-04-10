class PostsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]

  def index
    @posts = Post.all.order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
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
    @post = Current.user.posts.find(params[:id])
  end

  def update
    @post = Current.user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Current.user.posts.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "Post was successfully deleted."
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
