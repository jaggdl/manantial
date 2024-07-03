class CreateConnectionSets < ActiveRecord::Migration[7.0]
  def change
    create_table :connection_sets do |t|
      t.string :token
      t.string :domain

      t.timestamps
    end
  end
end
