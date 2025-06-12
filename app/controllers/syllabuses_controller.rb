class SyllabusesController < ApplicationController
  before_action :set_university
  before_action :set_syllabus, only: [:show, :edit, :update, :destroy]

  def index
    @syllabuses = @university.syllabuses.order(created_at: :desc)
  end

  def show
  end

  def new
    @syllabus = @university.syllabuses.build
  end

  def create
    @syllabus = @university.syllabuses.build(syllabus_params)
    if @syllabus.save
      redirect_to [@university, @syllabus], notice: 'シラバスが正常に投稿されました。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @syllabus.update(syllabus_params)
      redirect_to [@university, @syllabus], notice: 'シラバスが正常に更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @syllabus.destroy
    redirect_to university_syllabuses_path(@university), notice: 'シラバスが正常に削除されました。'
  end

  def search
    @syllabuses = @university.syllabuses.where('title LIKE ? OR content LIKE ? OR course_name LIKE ? OR professor LIKE ?',
      "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    render :index
  end

  private

  def set_university
    @university = University.find(params[:university_id])
  end

  def set_syllabus
    @syllabus = @university.syllabuses.find(params[:id])
  end

  def syllabus_params
    params.require(:syllabus).permit(:title, :content, :faculty, :department, :course_name, :professor, :year, :semester, :credits)
  end
end
