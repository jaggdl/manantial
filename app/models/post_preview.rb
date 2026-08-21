class PostPreview
  attr_reader :title, :preview_text, :created_at, :user_name, :user_avatar_url, :preview_image_urls, :preview_images, :preview_video_urls, :url, :local, :pinned

  def self.for_owner(owner, context)
    owner.posts.by_pinned_first.map { |post| from_post(post, context) }
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
      preview_images: post.preview_images.map { |blob| image_data(blob, context) },
      preview_video_urls: post.preview_videos.map { |blob| context.url_for(blob) },
      url: context.post_path(post),
      local: true,
      pinned: post.pinned?
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
      preview_images: remote_post.preview_image_urls.map { |url| { url: url, width: nil, height: nil } },
      preview_video_urls: remote_post.preview_video_urls,
      url: remote_post.url,
      local: false,
      pinned: false
    )
  end

  def initialize(title:, preview_text:, created_at:, article:, user_name:, user_avatar_url:, preview_image_urls: [], preview_images: [], preview_video_urls: [], url:, local:, pinned: false)
    @title = title
    @preview_text = preview_text
    @created_at = created_at
    @article = article
    @user_name = user_name
    @user_avatar_url = user_avatar_url
    @preview_image_urls = preview_image_urls
    @preview_images = preview_images
    @preview_video_urls = preview_video_urls
    @url = url
    @local = local
    @pinned = pinned
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

  private

  def self.image_data(blob, context)
    {
      url: context.url_for(blob.representation(resize_to_limit: [800, 800])),
      large_url: context.url_for(blob),
      width: blob.metadata[:width],
      height: blob.metadata[:height]
    }
  end
end
