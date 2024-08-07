module PostsHelper
  def visibility_icon(post)
    visibility_icons = {
      public: 'globe-alt',
      connections: 'link',
      hidden: 'eye-slash',
    }

    heroicon(visibility_icons[post.visibility_label.to_sym])
  end
end
