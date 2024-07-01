class CreateConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :connections do |t|
      t.string :domain, null: false
      t.string :token

      t.timestamps
    end

    add_index :connections, :domain, unique: true
  end
end
