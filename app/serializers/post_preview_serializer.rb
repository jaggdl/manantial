class PostPreviewSerializer < ActiveModel::Serializer
  attributes :title, :description, :slug, :created_at, :updated_at, :preview_image, :total_unique_views
end
