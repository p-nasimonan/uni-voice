class User < ApplicationRecord
  has_secure_password
  has_many :comments, dependent: :destroy

  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :university_email_domain

  validates :user_id, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9]+\z/, message: "は半角英数字のみ使用できます" },
            length: { is: 16 }

  validates :name, length: { maximum: 30 },
            allow_nil: true

  validates :password, presence: true, length: { minimum: 6 }, on: :create

  before_validation :set_default_name, if: -> { name.blank? }
  before_validation :generate_user_id, on: :create

  def university_domain
    email.split("@").last if email.present?
  end

  def base_domain
    # サブドメインを除いた基本ドメインを取得
    # 例: ie.u-ryukyu.ac.jp -> u-ryukyu.ac.jp
    return nil unless email.present?

    domain_parts = university_domain.split(".")
    # 最後の3つの部分を取得 (u-ryukyu.ac.jp)
    return domain_parts.last(3).join(".") if domain_parts.length >= 3
    university_domain
  end

  def university
    return nil unless email.present?

    University.find_by(email_domain: base_domain)
  end

  private

  def set_default_name
    self.name = "ななし"
  end

  def generate_user_id
    return if user_id.present?
    loop do
      self.user_id = SecureRandom.alphanumeric(16).downcase
      break unless User.exists?(user_id: user_id)
    end
  end

  def university_email_domain
    return unless email.present?

    # Universityモデルに登録されているドメインかチェック
    unless University.exists?(email_domain: base_domain)
      errors.add(:email, "登録されていない大学のメールアドレスです")
    end
  end
end
