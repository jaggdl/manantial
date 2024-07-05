class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :full_name
      t.string :short_name
      t.text :description

      t.timestamps
    end
  end
end
