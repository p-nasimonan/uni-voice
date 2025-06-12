class University < ApplicationRecord
  has_many :syllabuses, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :email_domain, presence: true, uniqueness: true
end 