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

    Nokogiri::HTML(html_content, nil, "UTF-8")
  rescue => e
    Rails.logger.error "HTML fetch error for URL #{@url}: #{e.message}"
    raise ScrapingError, "HTMLの取得に失敗しました: #{e.message}"
  end

  # @description タイトルを抽出
  def extract_title(doc, config)
    selectors = config[:title_selectors] || default_title_selectors
    extract_text(doc, selectors) || "タイトルが見つかりませんでした"
  end

  # @description 内容を抽出
  def extract_content(doc, config)
    selectors = config[:content_selectors] || default_content_selectors
    extract_text(doc, selectors) || "内容が見つかりませんでした"
  end

  # @description 学部・学科を抽出
  def extract_faculty_department(doc, config)
    selectors = config[:faculty_department_selectors] || default_faculty_department_selectors
    extract_text(doc, selectors) || ""
  end

  # @description 科目番号を抽出
  def extract_course_number(doc, config)
    selectors = config[:course_number_selectors] || default_course_number_selectors
    extract_text(doc, selectors) || ""
  end

  # @description 担当教員を抽出
  def extract_professor(doc, config)
    selectors = config[:professor_selectors] || default_professor_selectors
    extract_text(doc, selectors) || ""
  end

  # @description 年度を抽出
  def extract_year(doc, config)
    selectors = config[:year_selectors] || default_year_selectors
    year_text = extract_text(doc, selectors)
    year = year_text&.match(/\d{4}/)&.[](0)
    year || Date.current.year
  end

  # @description 学期を抽出
  def extract_semester(doc, config)
    selectors = config[:semester_selectors] || default_semester_selectors
    semester_text = extract_text(doc, selectors)
    semester_text || ""
  end

  # @description 曜日時限を抽出
  def extract_day_period(doc, config)
    selectors = config[:day_period_selectors] || default_day_period_selectors
    extract_text(doc, selectors) || ""
  end

  # @description 単位数を抽出
  def extract_credits(doc, config)
    selectors = config[:credits_selectors] || default_credits_selectors
    credits_text = extract_text(doc, selectors)
    credits = credits_text&.match(/\d+(?:\.\d+)?/)&.[](0)
    credits || 2
  end

  # @description テキストを抽出する共通メソッド
  def extract_text(doc, selectors)
    selectors.each do |selector|
      element = doc.css(selector).first
      if element&.text&.strip&.present?
        # テキストをUTF-8で正規化して返す
        text = element.text.strip
        # HTMLエンティティをデコード
        text = CGI.unescapeHTML(text)
        # 改行や空白を適切に処理
        text = text.gsub(/\s+/, " ").strip
        return text if text.present?
      end
    end
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
