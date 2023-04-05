class CreateBanks < ActiveRecord::Migration[7.0]
  def change
    create_table :banks do |t|
      t.string :full_name, null: false
      t.string :abbrv, null: false

      t.timestamps
    end
    add_index :banks, :abbrv, unique: true
  end
end
