# @fileoverview シラバススクレイピングサービス
# @description シラバス情報を自動取得するためのサービスクラス

require "cgi"

class SyllabusScraperService
  # @description スクレイピングを実行する
  # @param url [String] スクレイピング対象のURL
  # @param university [University] 大学オブジェクト（オプション）
  # @return [Hash] スクレイピング結果
  def self.scrape(url, university = nil)
    new(url, university).scrape
  end

  def initialize(url, university = nil)
    @url = url
    @university = university
    validate_url!
  end

  # @description メインのスクレイピング処理
  # @return [Hash] スクレイピング結果
  def scrape
    # 適切な間隔でのアクセス
    sleep(1)

    # HTMLを取得して解析
    doc = fetch_and_parse_html

    # 大学別設定を取得
    config = get_scraping_config

    # 情報を抽出
    {
      title: extract_title(doc, config),
      content: extract_content(doc, config),
      faculty_department: extract_faculty_department(doc, config),
      course_number: extract_course_number(doc, config),
      professor: extract_professor(doc, config),
      year: extract_year(doc, config),
      semester: extract_semester(doc, config),
      day_period: extract_day_period(doc, config),
      credits: extract_credits(doc, config)
    }
  rescue => e
    Rails.logger.error "Scraping error for URL #{@url}: #{e.message}"
    raise ScrapingError, "スクレイピングに失敗しました: #{e.message}"
  end

  private

  # @description スクレイピング設定を取得
  def get_scraping_config
    if @university
      UniversityScrapingConfig.config_for(@university)
    else
      UniversityScrapingConfig.config_for(University.new(name: "default"))
    end
  end

  # @description URLの妥当性をチェック
  def validate_url!
    unless @url.present? && valid_url?(@url)
      raise ArgumentError, "有効なURLを指定してください"
    end
  end

  # @description URLの形式をチェック
  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  # @description HTMLを取得して解析
  def fetch_and_parse_html
    require "nokogiri"
    require "open-uri"

    # User-Agentを設定してブロックを回避
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

    # UTF-8でHTMLを取得して解析
    html_content = URI.open(@url, "User-Agent" => user_agent) do |f|
      f.read.force_encoding("UTF-8")
    end

    # デバッグ用にHTMLを保存（開発環境でのみ）
    if Rails.env.development?
      debug_file_path = Rails.root.join("tmp", "debug_scraped_html_#{Time.current.to_i}.html")
      File.write(debug_file_path, html_content)
      Rails.logger.debug "HTML saved to: #{debug_file_path}"
    end

    doc = Nokogiri::HTML(html_content, nil, "UTF-8")
    Rails.logger.debug "HTML parsed successfully. Title: #{doc.title}"
    doc
  rescue => e
    Rails.logger.error "HTML fetch error for URL #{@url}: #{e.message}"
    raise ScrapingError, "HTMLの取得に失敗しました: #{e.message}"
  end

  # @description タイトルを抽出
  def extract_title(doc, config)
    Rails.logger.debug "Extracting title..."
    selectors = config[:title_selectors] || default_title_selectors
    result = extract_text(doc, selectors) || "タイトルが見つかりませんでした"
    Rails.logger.debug "Title extracted: #{result}"
    result
  end

  # @description 内容を抽出
  def extract_content(doc, config)
    Rails.logger.debug "Extracting content..."
    selectors = config[:content_selectors] || default_content_selectors
    result = extract_text(doc, selectors) || "内容が見つかりませんでした"
    Rails.logger.debug "Content extracted: #{result[0..100]}..." # 最初の100文字のみログ出力
    result
  end

  # @description 学部・学科を抽出
  def extract_faculty_department(doc, config)
    Rails.logger.debug "Extracting faculty_department..."
    selectors = config[:faculty_department_selectors] || default_faculty_department_selectors
    result = extract_text(doc, selectors) || ""
    Rails.logger.debug "Faculty department extracted: #{result}"
    result
  end

  # @description 科目番号を抽出
  def extract_course_number(doc, config)
    Rails.logger.debug "Extracting course_number..."
    selectors = config[:course_number_selectors] || default_course_number_selectors
    result = extract_text(doc, selectors) || ""
    Rails.logger.debug "Course number extracted: #{result}"
    result
  end

  # @description 担当教員を抽出
  def extract_professor(doc, config)
    Rails.logger.debug "Extracting professor..."
    selectors = config[:professor_selectors] || default_professor_selectors
    result = extract_text(doc, selectors) || ""
    Rails.logger.debug "Professor extracted: #{result}"
    result
  end

  # @description 年度を抽出
  def extract_year(doc, config)
    Rails.logger.debug "Extracting year..."
    selectors = config[:year_selectors] || default_year_selectors
    year_text = extract_text(doc, selectors)
    year = year_text&.match(/\d{4}/)&.[](0)
    result = year || Date.current.year
    Rails.logger.debug "Year extracted: #{result} (from text: #{year_text})"
    result
  end

  # @description 学期を抽出
  def extract_semester(doc, config)
    Rails.logger.debug "Extracting semester..."
    selectors = config[:semester_selectors] || default_semester_selectors
    result = extract_text(doc, selectors) || ""
    Rails.logger.debug "Semester extracted: #{result}"
    result
  end

  # @description 曜日時限を抽出
  def extract_day_period(doc, config)
    Rails.logger.debug "Extracting day_period..."
    selectors = config[:day_period_selectors] || default_day_period_selectors
    result = extract_text(doc, selectors) || ""
    Rails.logger.debug "Day period extracted: #{result}"
    result
  end

  # @description 単位数を抽出
  def extract_credits(doc, config)
    Rails.logger.debug "Extracting credits..."
    selectors = config[:credits_selectors] || default_credits_selectors
    credits_text = extract_text(doc, selectors)
    credits = credits_text&.match(/\d+(?:\.\d+)?/)&.[](0)
    result = credits || 2
    Rails.logger.debug "Credits extracted: #{result} (from text: #{credits_text})"
    result
  end

  # @description テキストを抽出する共通メソッド
  def extract_text(doc, selectors)
    selectors.each_with_index do |selector, index|
      Rails.logger.debug "Trying selector #{index + 1}/#{selectors.length}: #{selector}"
      element = doc.css(selector).first
      if element&.text&.strip&.present?
        # テキストをUTF-8で正規化して返す
        text = element.text.strip
        # HTMLエンティティをデコード
        text = CGI.unescapeHTML(text)
        # 改行や空白を適切に処理
        text = text.gsub(/\s+/, " ").strip
        Rails.logger.debug "Found text with selector '#{selector}': #{text}"
        return text if text.present?
      else
        Rails.logger.debug "No text found with selector: #{selector}"
      end
    end
    Rails.logger.debug "No text found with any of the selectors"
    nil
  end

  # デフォルトセレクター
  def default_title_selectors
    [ "h1", ".title", ".syllabus-title", ".course-title", "[class*=\"title\"]", "title" ]
  end

  def default_content_selectors
    [ ".content", ".syllabus-content", ".description", ".course-description", ".outline", ".summary", "[class*=\"content\"]", "[class*=\"description\"]" ]
  end

  def default_faculty_department_selectors
    [ ".faculty", ".department-info", ".school", ".department", ".course-info", ".major", "[class*=\"faculty\"]", "[class*=\"school\"]", "[class*=\"department\"]" ]
  end

  def default_course_number_selectors
    [ ".course-number", ".course-code", ".code", ".number", "[class*=\"course-number\"]", "[class*=\"course-code\"]" ]
  end

  def default_professor_selectors
    [ ".professor", ".instructor", ".teacher", ".lecturer", "[class*=\"professor\"]", "[class*=\"instructor\"]" ]
  end

  def default_year_selectors
    [ ".year", ".academic-year", ".fiscal-year", "[class*=\"year\"]" ]
  end

  def default_semester_selectors
    [ ".semester", ".term", ".period", "[class*=\"semester\"]", "[class*=\"term\"]" ]
  end

  def default_day_period_selectors
    [ ".day-period", ".time-period", ".schedule", "[class*=\"day-period\"]", "[class*=\"time-period\"]" ]
  end

  def default_credits_selectors
    [ ".credits", ".units", ".credit-hours", "[class*=\"credit\"]", "[class*=\"unit\"]" ]
  end

  # @description スクレイピングエラークラス
  class ScrapingError < StandardError; end
end
