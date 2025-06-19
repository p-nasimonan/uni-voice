# @fileoverview シラバスコントローラー
# @description シラバスのCRUD操作を管理します

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
      redirect_to university_syllabus_path(@university, @syllabus), notice: 'シラバスが正常に作成されました。'
    else
      Rails.logger.error "Syllabus creation failed: #{@syllabus.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @syllabus.update(syllabus_params)
      redirect_to university_syllabus_path(@university, @syllabus), notice: 'シラバスが正常に更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @syllabus.destroy
    redirect_to university_path(@university), notice: 'シラバスが正常に削除されました。'
  end

  def search
    @universities = University.all.order(:name)
    @syllabuses = Syllabus.includes(:university)
    
    if params[:query].present?
      @syllabuses = @syllabuses.where("title LIKE ? OR content LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
    
    if params[:university_id].present?
      @syllabuses = @syllabuses.where(university_id: params[:university_id])
    end
    
    @syllabuses = @syllabuses.page(params[:page]).per(12)
  end

  # @description シラバス情報を自動取得するアクション
  def scrape
    url = params[:url]
    
    unless url.present?
      render json: { error: 'URLが指定されていません' }, status: :bad_request
      return
    end

    begin
      # サービスクラスを使用してスクレイピング実行（大学情報も渡す）
      scraped_data = SyllabusScraperService.scrape(url, @university)
      render json: { success: true, data: scraped_data }
      
    rescue SyllabusScraperService::ScrapingError => e
      render json: { error: e.message }, status: :internal_server_error
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue => e
      Rails.logger.error "Unexpected error in scrape action: #{e.message}"
      render json: { error: "予期しないエラーが発生しました" }, status: :internal_server_error
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
    params.require(:syllabus).permit(:title, :faculty_department, :course_number, :professor, :year, :semester, :day_period, :credits, :content, :url)
  end
end
