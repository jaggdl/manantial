class ChangeNameToLimitInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :name, :string, limit: 50
  end
end
