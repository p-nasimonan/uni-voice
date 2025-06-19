class RemoveFacultyAndDepartmentFromSyllabuses < ActiveRecord::Migration[8.0]
  def change
    remove_column :syllabuses, :faculty, :string
    remove_column :syllabuses, :department, :string
  end
end
