# @fileoverview 大学別スクレイピング設定
# @description 各大学のシラバスサイトに特化したスクレイピング設定を管理します

class UniversityScrapingConfig
  # @description 大学別のスクレイピング設定を取得
  # @param university [University] 大学オブジェクト
  # @return [Hash] スクレイピング設定
  def self.config_for(university)
    new(university).config
  end

  def initialize(university)
    @university = university
  end

  # @description 大学別の設定を取得
  def config
    case @university.name
    when /北海道大学/
      hokkaido_university_config
    when /琉球大学/
      ryukyu_university_config
    else
      default_config
    end
  end

  private


  # @description 北海道大学の設定
  def hokkaido_university_config
    {
      title_selectors: ['h1', '.title', '.course-title'],
      content_selectors: ['.content', '.description', '.syllabus'],
      faculty_department_selectors: ['.faculty', '.school', '.department', '.major'],
      course_number_selectors: ['.course-number', '.course-code', '.code'],
      professor_selectors: ['.professor', '.instructor'],
      year_selectors: ['.year', '.academic-year'],
      semester_selectors: ['.semester', '.term'],
      day_period_selectors: ['.day-period', '.schedule', '.time'],
      credits_selectors: ['.credits', '.units'],
      base_url: 'https://www.hokudai.ac.jp',
      requires_authentication: false
    }
  end

  # @description 琉球大学の設定
  def ryukyu_university_config
    {
      title_selectors: [
        '#ctl00_phContents_Detail_dcl_lct_name_double_lblCategory',
        '.ItemName_value span',
        'h1',
        '.title'
      ],
      content_selectors: [
        '#ctl00_phContents_Detail_dcl_outline_lblCategory',
        '.syl_contents',
        '.ItemName span'
      ],
      faculty_department_selectors: [
        '#ctl00_phContents_Detail_dcl_fac_name_lblCategory',
        '.ItemName_value span'
      ],
      course_number_selectors: [
        '#ctl00_phContents_Detail_dcl_num_cd_double_lblCategory',
        '.ItemName_value span'
      ],
      professor_selectors: [
        '#ctl00_phContents_Detail_dcl_syl_staff_name_double_lblCategory',
        '.ItemName_value span'
      ],
      year_selectors: [
        '#ctl00_phContents_Detail_dcl_lct_year_lblCategory',
        '.ItemName_value span'
      ],
      semester_selectors: [
        '#ctl00_phContents_Detail_dcl_term_name_lblCategory',
        '.ItemName_value span'
      ],
      day_period_selectors: [
        '#ctl00_phContents_Detail_dcl_day_period_lblCategory',
        '.ItemName_value span'
      ],
      credits_selectors: [
        '#ctl00_phContents_Detail_dcl_credits_lblCategory',
        '.ItemName_value span'
      ],
      base_url: 'https://portal.u-ryukyu.ac.jp',
      requires_authentication: true
    }
  end

  # @description デフォルト設定
  def default_config
    {
      title_selectors: ['h1', '.title', '.syllabus-title', '.course-title'],
      content_selectors: ['.content', '.syllabus-content', '.description', '.course-description'],
      faculty_department_selectors: ['.faculty', '.department-info', '.school', '.department', '.course-info', '.major'],
      course_number_selectors: ['.course-number', '.course-code', '.code', '.number'],
      professor_selectors: ['.professor', '.instructor', '.teacher'],
      year_selectors: ['.year', '.academic-year', '.fiscal-year'],
      semester_selectors: ['.semester', '.term', '.period'],
      day_period_selectors: ['.day-period', '.schedule', '.time', '.day', '.period'],
      credits_selectors: ['.credits', '.units', '.credit-hours'],
      base_url: nil,
      requires_authentication: false
    }
  end
end 