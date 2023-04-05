class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :password, null: false
      t.string :full_name, null: false
      t.boolean :is_admin, null: false, default: false
      t.float :total_balance, null: false, default: 0.0
      t.timestamps
    end
    add_index :users, :username, unique: true
  end
end
