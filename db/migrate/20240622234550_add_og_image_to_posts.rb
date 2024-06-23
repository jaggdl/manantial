class AddOgImageToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :og_image, :string
  end
end
