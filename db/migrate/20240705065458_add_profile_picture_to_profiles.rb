class AddProfilePictureToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :profile_picture, :string
  end
end
