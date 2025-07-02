# @fileoverview 大学別スクレイピング設定
# @description 各大学のシラバスサイトに特化したスクレイピング設定を管理します
# 現在は琉球大学のみ対応

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
    when /琉球大学/
      ryukyu_university_config
    else
      # 現在は琉球大学のみ対応
      ryukyu_university_config
    end
  end

  private

  # @description 琉球大学の設定
  def ryukyu_university_config
    {
      title_selectors: [
        "#ctl00_phContents_Detail_dcl_lct_name_double_lblCategory",
        "span[id*='dcl_lct_name_double_lblCategory']",
        ".ItemName_value span",
        "h1",
        ".title"
      ],
      content_selectors: [
        "#ctl00_phContents_Detail_dcl_outline_lblCategory",
        "span[id*='dcl_outline_lblCategory']",
        ".syl_contents",
        ".ItemName span"
      ],
      faculty_department_selectors: [
        "#ctl00_phContents_Detail_dcl_fac_name_lblCategory",
        "span[id*='dcl_fac_name_lblCategory']",
        ".ItemName_value span"
      ],
      course_number_selectors: [
        "#ctl00_phContents_Detail_dcl_num_cd_double_lblCategory",
        "span[id*='dcl_num_cd_double_lblCategory']",
        "#ctl00_phContents_Detail_dcl_syl_lct_cd_lblCategory",
        "span[id*='dcl_syl_lct_cd_lblCategory']",
        ".ItemName_value span"
      ],
      professor_selectors: [
        "#ctl00_phContents_Detail_dcl_syl_staff_name_double_lblCategory",
        "span[id*='dcl_syl_staff_name_double_lblCategory']",
        ".ItemName_value span"
      ],
      year_selectors: [
        "#ctl00_phContents_Detail_dcl_lct_year_lblCategory",
        "span[id*='dcl_lct_year_lblCategory']",
        ".ItemName_value span"
      ],
      semester_selectors: [
        "#ctl00_phContents_Detail_dcl_term_name_lblCategory",
        "span[id*='dcl_term_name_lblCategory']",
        ".ItemName_value span"
      ],
      day_period_selectors: [
        "#ctl00_phContents_Detail_dcl_day_period_lblCategory",
        "span[id*='dcl_day_period_lblCategory']",
        ".ItemName_value span"
      ],
      credits_selectors: [
        "#ctl00_phContents_Detail_dcl_credits_lblCategory",
        "span[id*='dcl_credits_lblCategory']",
        ".ItemName_value span"
      ],
      base_url: "https://portal.u-ryukyu.ac.jp",
      requires_authentication: true
    }
  end
end
