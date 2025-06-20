class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false, default: 'ななし'
      t.string :user_id, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :user_id, unique: true
  end
end
