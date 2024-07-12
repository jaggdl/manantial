class FeedController < ApplicationController
  def index
    connection_sets = Connection::Set.all

    @latest_posts = connection_sets.map(&:latest_posts).flatten

    @latest_posts = @latest_posts.map do |post|
      OpenStruct.new(post)
    end

    @latest_posts.sort_by!(&:created_at).reverse!
  end
end
