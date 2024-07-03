class CreateConnectionOuts < ActiveRecord::Migration[7.0]
  def change
    create_table :connection_outs do |t|
      t.string :nonce
      t.string :domain

      t.timestamps
    end

    add_index :connection_outs, :domain, unique: true
  end
end
