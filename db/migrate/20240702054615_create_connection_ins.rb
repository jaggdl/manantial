class CreateConnectionIns < ActiveRecord::Migration[7.0]
  def change
    create_table :connection_ins do |t|
      t.string :nonce
      t.string :domain
      t.string :message

      t.timestamps
    end

    add_index :connection_ins, :domain, unique: true
  end
end
