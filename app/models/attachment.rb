class Attachment < ApplicationRecord
  belongs_to :comment

  has_one_attached :file

  validates :file, presence: true
  validates :filename, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  validate :acceptable_file_type
  validate :file_size_limit

  before_save :set_file_metadata

  ALLOWED_FILE_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    image/jpeg
    image/png
    image/gif
    text/plain
    text/csv
  ].freeze

  MAX_FILE_SIZE = 10.megabytes

  def file_type_icon
    case content_type
    when "application/pdf"
      "pdf"
    when /word/
      "word"
    when /excel/, /spreadsheet/
      "excel"
    when /powerpoint/, /presentation/
      "powerpoint"
    when /image/
      "image"
    else
      "file"
    end
  end

  def human_file_size
    return "0 B" if file_size.zero?

    units = %w[B KB MB GB]
    base = 1024
    exp = (Math.log(file_size) / Math.log(base)).to_i
    exp = [ exp, units.length - 1 ].min

    "%.1f %s" % [ file_size.to_f / base**exp, units[exp] ]
  end

  private

  def acceptable_file_type
    return unless file.attached?

    unless ALLOWED_FILE_TYPES.include?(file.content_type)
      errors.add(:file, "\u306E\u30D5\u30A1\u30A4\u30EB\u5F62\u5F0F\u306F\u8A31\u53EF\u3055\u308C\u3066\u3044\u307E\u305B\u3093")
    end
  end

  def file_size_limit
    return unless file.attached?

    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, "\u306E\u30B5\u30A4\u30BA\u306F10MB\u4EE5\u4E0B\u306B\u3057\u3066\u304F\u3060\u3055\u3044")
    end
  end

  def set_file_metadata
    if file.attached?
      self.filename = file.filename.to_s
      self.file_size = file.byte_size
      self.content_type = file.content_type
    end
  end
end
