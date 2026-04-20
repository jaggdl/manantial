class AddNonceToConnections < ActiveRecord::Migration[8.1]
  def change
    add_column :connections, :nonce, :string
    add_index :connections, :nonce, unique: true
  end
end
