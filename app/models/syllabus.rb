class Syllabus < ApplicationRecord
  belongs_to :university
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true
  validates :professor, presence: true
  validates :year, presence: true
  validates :semester, presence: true
  validates :credits, presence: true
  validates :url, presence: true, format: { with: URI.regexp, message: "有効なURLを入力してください" }
  validates :faculty_department, presence: true
  validates :course_number, presence: true
  validates :day_period, presence: true

  def average_rating
    review_comments = comments.reviews.where.not(rating: nil)
    return 0 if review_comments.empty?

    (review_comments.sum(:rating).to_f / review_comments.count).round(1)
  end

  def rating_count
    comments.reviews.where.not(rating: nil).count
  end
end
