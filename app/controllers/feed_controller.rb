class FeedController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :track_ahoy_visit

  def index
    connection_sets = Connection::Set.all

    @latest_posts = connection_sets.map do |connection_set|
      latest_posts = connection_set.latest_posts

      latest_posts.map do |post|
        enrich_post(post, connection_set)
      end
    end.flatten

    @latest_posts.sort_by!(&:created_at).reverse!
  end

  def show
    connection_id = params[:connection_id]
    post_id = params[:post_id]

    connection = Connection::Set.find(connection_id)
    post = connection.get_post(post_id)
    @post = enrich_post(post, connection)
  end

  private

  def enrich_post(post, post_connection)
    struct_post = OpenStruct.new(post)
    struct_post.preview_image = struct_post.preview_image.deep_symbolize_keys
    struct_post.author = post_connection
    struct_post
  end
end
