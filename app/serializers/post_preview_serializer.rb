class PostPreviewSerializer < ActiveModel::Serializer
  attributes :title, :description, :slug, :created_at, :updated_at, :cover_image

  def cover_image
    object.image.lg.url
  end
end
