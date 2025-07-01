class University < ApplicationRecord
  has_many :syllabuses, dependent: :destroy
  has_many :users, -> { joins(:university).where(universities: { id: :id }) }, class_name: "User"

  validates :name, presence: true, uniqueness: true
  validates :email_domain, presence: true, uniqueness: true

  # ユーザーのメールドメインがこの大学に属するかチェック
  def matches_email?(email)
    return false unless email.present? && email_domain.present?

    user_domain = email.split("@").last
    domain_parts = user_domain.split(".")
    base_domain = domain_parts.last(3).join(".") if domain_parts.length >= 3

    base_domain == email_domain || user_domain == email_domain
  end
end
