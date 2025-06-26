class Avo::Resources::Syllabus < Avo::BaseResource
  self.title = :title
  self.includes = [ :university ]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], title_cont: params[:q], content_cont: params[:q], professor_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id, hide_on: [ :index, :show ]
    field :title, as: :text, required: true, sortable: true
    field :university, as: :belongs_to, required: true, sortable: true
    field :faculty_department, as: :text, sortable: true
    field :course_number, as: :text, sortable: true
    field :professor, as: :text, sortable: true
    field :year, as: :number, sortable: true
    field :semester, as: :text, sortable: true
    field :day_period, as: :text, sortable: true
    field :credits, as: :number, sortable: true
    field :content, as: :textarea, hide_on: [ :index ]
    field :url, as: :text, hide_on: [ :index ]
  end

  def filters
    # フィルターは後で実装
  end

  def actions
    # アクションは後で実装
  end
end
