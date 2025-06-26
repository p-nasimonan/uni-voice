class Avo::Resources::University < Avo::BaseResource
  self.title = :name
  self.includes = [ :syllabuses ]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id, hide_on: [ :index, :show ]
    field :name, as: :text, required: true, sortable: true
    field :email_domain, as: :text, required: true, sortable: true
    field :syllabuses_count, as: :text, only_on: [ :index, :show ]
    field :syllabuses, as: :has_many, hide_on: [ :index ]
  end

  def actions
  end
end
