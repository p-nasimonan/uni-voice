class Syllabus < ApplicationRecord
  belongs_to :university
  validates :title, presence: true
  validates :content, presence: true
  validates :professor, presence: true
  validates :year, presence: true
  validates :semester, presence: true
  validates :credits, presence: true
  validates :url, presence: true, format: { with: URI::regexp, message: "有効なURLを入力してください" }
  validates :faculty_department, presence: true
  validates :course_number, presence: true
  validates :day_period, presence: true
end
