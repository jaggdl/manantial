class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.text :markdown
      t.string :slug

      t.timestamps
    end
  end
end
