class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :og_image]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  skip_before_action :track_ahoy_visit, only: [:og_image]

  def index
    @posts = Post.order(created_at: :desc).select(&:translated?)
  end

  def show
    unless @post.translated?
      if user_signed_in?
        redirect_to edit_post_path(@post), alert: I18n.t('posts.alerts.translate_before_viewing')
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
      redirect_to @post, notice: I18n.t('posts.notices.created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      @post.enqueue_og_image_generation
      redirect_to @post, notice: I18n.t('posts.notices.updated')
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: I18n.t('posts.notices.destroyed')
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

  def set_profile
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :markdown, :image)
  end
end
