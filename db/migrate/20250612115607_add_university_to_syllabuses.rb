class AddUniversityToSyllabuses < ActiveRecord::Migration[8.0]
  def change
    add_reference :syllabuses, :university, null: false, foreign_key: true
  end
end
