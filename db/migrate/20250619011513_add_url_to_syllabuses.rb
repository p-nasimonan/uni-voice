class AddUrlToSyllabuses < ActiveRecord::Migration[8.0]
  def change
    add_column :syllabuses, :url, :string
  end
end
