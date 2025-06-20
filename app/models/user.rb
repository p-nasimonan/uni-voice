class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :user_id, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9]+\z/, message: "は半角英数字のみ使用できます" },
            length: { is: 16 }

  validates :name, length: { maximum: 30 },
            allow_nil: true

  before_validation :set_default_name, if: -> { name.blank? }
  before_validation :generate_user_id, on: :create

  private

  def set_default_name
    self.name = 'ななし'
  end

  def generate_user_id
    return if user_id.present?
    loop do
      self.user_id = SecureRandom.alphanumeric(16).downcase
      break unless User.exists?(user_id: user_id)
    end
  end
end 