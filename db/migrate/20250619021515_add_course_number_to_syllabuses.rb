class AddCourseNumberToSyllabuses < ActiveRecord::Migration[8.0]
  def change
    add_column :syllabuses, :course_number, :string
  end
end
