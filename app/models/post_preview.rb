class PostPreview
  attr_reader :title, :preview_text, :created_at, :user_name, :user_avatar_url, :preview_image_urls, :url, :local

  def self.for_owner(owner, context)
    owner.posts.order(created_at: :desc).map { |post| from_post(post, context) }
  end

  def self.federated(owner, context)
    local = for_owner(owner, context)
    remote = Peers::Connection.active.flat_map(&:fetch_posts).map { |remote| from_remote(remote) }
    (local + remote).sort_by(&:created_at).reverse
  end

  def self.from_post(post, context)
    new(
      title: post.title,
      preview_text: post.preview_text(250),
      created_at: post.created_at,
      article: post.article?,
      user_name: post.user.name,
      user_avatar_url: post.user.avatar.attached? ? context.url_for(post.user.avatar.variant(resize_to_limit: [128, 128])) : nil,
      preview_image_urls: post.preview_images.map { |blob| context.url_for(blob.representation(resize_to_limit: [800, 800])) },
      url: context.post_path(post),
      local: true
    )
  end

  def self.from_remote(remote_post)
    new(
      title: remote_post.title,
      preview_text: remote_post.preview_text,
      created_at: remote_post.created_at,
      article: remote_post.article?,
      user_name: remote_post.user.name,
      user_avatar_url: remote_post.user.avatar_url,
      preview_image_urls: remote_post.preview_image_urls,
      url: remote_post.url,
      local: false
    )
  end

  def initialize(title:, preview_text:, created_at:, article:, user_name:, user_avatar_url:, preview_image_urls:, url:, local:)
    @title = title
    @preview_text = preview_text
    @created_at = created_at
    @article = article
    @user_name = user_name
    @user_avatar_url = user_avatar_url
    @preview_image_urls = preview_image_urls
    @url = url
    @local = local
  end

  def article?
    @article
  end

  def local?
    @local
  end

  def to_partial_path
    "posts/post_preview"
  end
end
