class SyllabusesController < ApplicationController
  before_action :set_university, except: [:search]
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
    @universities = University.all.order(:name)
    @syllabuses = Syllabus.includes(:university)
    
    # 検索クエリがある場合
    if params[:query].present?
      @syllabuses = @syllabuses.where(
        "title ILIKE :query OR professor ILIKE :query",
        query: "%#{params[:query]}%"
      )
    end
    
    # 大学が選択されている場合
    if params[:university_id].present?
      @syllabuses = @syllabuses.where(university_id: params[:university_id])
    end
    
    @syllabuses = @syllabuses.page(params[:page]).per(12)
    
    respond_to do |format|
      format.html
      format.json { render json: @syllabuses }
    end
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
