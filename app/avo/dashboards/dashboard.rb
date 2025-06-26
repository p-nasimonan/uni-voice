class Avo::Dashboards::Dashboard < Avo::BaseDashboard
  self.id = "dashboard"
  self.name = "ダッシュボード"
  self.description = "uni-voice管理画面のメインダッシュボード"
  # self.grid_cols = 3
  # self.visible = -> do
  #   true
  # end

  def cards
    card Avo::Cards::TotalUniversities
  end

  def rows
    # 行は後で実装
  end
end
