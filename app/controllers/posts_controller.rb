class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :og_image]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @posts = Post.order(created_at: :desc).select(&:translated?)
  end

  def show
    unless @post.translated?
      if user_signed_in?
        redirect_to edit_post_path(@post), alert: 'Please translate the post before viewing.'
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      @post.enqueue_og_image_generation
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      @post.enqueue_og_image_generation
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end

  def og_image
    render(
      partial: 'posts/og_image',
      layout: 'layouts/og_image'
    )
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :markdown, :image)
  end
end
