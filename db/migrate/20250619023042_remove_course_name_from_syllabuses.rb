class RemoveCourseNameFromSyllabuses < ActiveRecord::Migration[8.0]
  def change
    remove_column :syllabuses, :course_name, :string
  end
end
