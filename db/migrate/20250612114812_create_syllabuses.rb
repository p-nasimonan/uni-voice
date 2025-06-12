class CreateSyllabuses < ActiveRecord::Migration[8.0]
  def change
    create_table :syllabuses do |t|
      t.string :title
      t.text :content
      t.string :university
      t.string :faculty
      t.string :department
      t.string :course_name
      t.string :professor
      t.integer :year
      t.string :semester
      t.integer :credits

      t.timestamps
    end
  end
end
