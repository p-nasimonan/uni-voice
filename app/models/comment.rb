class Comment < ApplicationRecord
  belongs_to :syllabus
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :attachments, dependent: :destroy

  enum :comment_type, {
    review: 0,
    file_share: 1,
    chat: 2
  }

  validates :content, presence: true, unless: :file_only_comment?
  validates :comment_type, presence: true
  validates :syllabus_id, presence: true
  validates :user_id, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }, if: :review?
  validate :review_cannot_have_parent
  validate :review_cannot_have_replies

  scope :reviews, -> { where(comment_type: :review) }
  scope :file_shares, -> { where(comment_type: :file_share) }
  scope :chats, -> { where(comment_type: :chat) }
  scope :recent, -> { order(created_at: :desc) }
  scope :top_level, -> { where(parent_id: nil) }

  def can_have_replies?
    !review?
  end

  def display_name
    is_anonymous? ? "匿名ユーザー" : user.name
  end

  def edited?
    edited_at.present?
  end

  private

  def file_only_comment?
    comment_type == "file_share" && attachments.any?
  end

  def review_cannot_have_parent
    if review? && parent_id.present?
      errors.add(:parent_id, "\u30EC\u30D3\u30E5\u30FC\u30B3\u30E1\u30F3\u30C8\u306F\u8FD4\u4FE1\u3067\u304D\u307E\u305B\u3093")
    end
  end

  def review_cannot_have_replies
    if review? && replies.any?
      errors.add(:base, "\u30EC\u30D3\u30E5\u30FC\u30B3\u30E1\u30F3\u30C8\u306B\u8FD4\u4FE1\u306F\u3067\u304D\u307E\u305B\u3093")
    end
  end
end
