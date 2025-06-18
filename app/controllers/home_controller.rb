class HomeController < ApplicationController
  def index
    @universities = University.all.order(:name)
    # ランダムなシラバスを取得（最大6件）
    @random_syllabuses = Syllabus.includes(:university)
                               .order(Arel.sql('RANDOM()'))
                               .limit(6)
  end
end
