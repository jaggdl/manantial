class AddVisibleToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :visible, :boolean, default: true
    add_index :posts, :visible
  end
end
