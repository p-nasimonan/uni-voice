class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :syllabus, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :comments }
      t.text :content
      t.integer :comment_type, null: false, default: 0
      t.integer :rating, null: true
      t.boolean :is_anonymous, default: false
      t.json :metadata
      t.datetime :edited_at

      t.timestamps
    end

    add_index :comments, [ :syllabus_id, :comment_type ]
    add_index :comments, [ :syllabus_id, :created_at ]
  end
end
