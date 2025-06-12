class Syllabus < ApplicationRecord
  belongs_to :university
  validates :title, presence: true
  validates :content, presence: true
  validates :course_name, presence: true
  validates :professor, presence: true
  validates :year, presence: true
  validates :semester, presence: true
  validates :credits, presence: true
end
