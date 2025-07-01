class CreateAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :attachments do |t|
      t.references :comment, null: false, foreign_key: true
      t.string :filename, null: false
      t.bigint :file_size
      t.string :content_type
      t.text :description

      t.timestamps
    end
  end
end
