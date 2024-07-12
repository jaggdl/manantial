class FeedController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :track_ahoy_visit

  def index
    connection_sets = Connection::Set.all

    @latest_posts = connection_sets.map(&:latest_posts).flatten

    @latest_posts = @latest_posts.map do |post|
      struct_post = OpenStruct.new(post)
      struct_post.preview_image = struct_post.preview_image.deep_symbolize_keys
      struct_post
    end

    @latest_posts.sort_by!(&:created_at).reverse!
  end
end
