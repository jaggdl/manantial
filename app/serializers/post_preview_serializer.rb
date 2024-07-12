class PostPreviewSerializer < ActiveModel::Serializer
  attributes :title, :description, :slug, :created_at, :updated_at, :image
end
