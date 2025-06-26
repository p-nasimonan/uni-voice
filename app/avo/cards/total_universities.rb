class Avo::Cards::TotalUniversities < Avo::BaseCard
  self.id = "total_universities"
  self.label = "登録大学数"
  self.description = "システムに登録されている大学の総数"
  self.cols = 1
  self.rows = 1
  self.initial_range = 30
  self.ranges = [ 7, 30, 60, 365, "TODAY", "MTD", "QTD", "YTD", "ALL" ]

  def query
    scope = University.all
    scope = scope.where(created_at: range) if range.present?
    scope.count
  end
end
