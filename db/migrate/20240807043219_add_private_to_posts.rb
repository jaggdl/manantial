class AddPrivateToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :private, :boolean, default: false
    add_index :posts, :private
  end
end
