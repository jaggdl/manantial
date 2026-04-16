class CreateConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :connections do |t|
      t.string :hostname, null: false
      t.string :status, default: "pending", null: false
      t.string :access_key
      t.string :peer_access_key
      t.text :error_message

      t.timestamps
    end

    add_index :connections, :hostname, unique: true
  end
end
