class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :nick_name, null: false
      t.float :balance, null: false, default: 1000.0
      t.references :user, null: false, foreign_key: true
      t.references :bank, null: false, foreign_key: true
      t.timestamps
    end
    add_index :accounts, :nick_name, unique: true
  end
end
