class AddFacultyDepartmentToSyllabuses < ActiveRecord::Migration[8.0]
  def change
    add_column :syllabuses, :faculty_department, :string
  end
end
