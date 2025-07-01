# @fileoverview シラバスコントローラー
# @description シラバスのCRUD操作を管理します

class SyllabusesController < ApplicationController
  before_action :set_university, except: [ :search ]
  before_action :set_syllabus, only: [ :show, :edit, :update, :destroy ]

  def index
    @syllabuses = @university.syllabuses.order(created_at: :desc)
  end

  def show
    @comments = @syllabus.comments.includes(:user, :attachments, :replies)
    @active_tab = params[:type] || "review"

    # 全てのコメントを取得してフロントエンドでフィルタリング
    @all_comments = @comments.top_level.order(created_at: :desc).page(params[:page]).per(20)

    # 各タブ用のコメントを個別に取得
    @review_comments = @comments.reviews.order(created_at: :desc)
    @file_share_comments = @comments.file_shares.top_level.order(created_at: :desc)
    @chat_comments = @comments.chats.top_level.order(created_at: :desc)

    @comment = Comment.new
  end

  def new
    @syllabus = @university.syllabuses.build
  end

  def create
    @syllabus = @university.syllabuses.build(syllabus_params)

    if @syllabus.save
      redirect_to university_syllabus_path(@university, @syllabus), notice: "\u30B7\u30E9\u30D0\u30B9\u304C\u6B63\u5E38\u306B\u4F5C\u6210\u3055\u308C\u307E\u3057\u305F\u3002"
    else
      Rails.logger.error "Syllabus creation failed: #{@syllabus.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @syllabus.update(syllabus_params)
      redirect_to university_syllabus_path(@university, @syllabus), notice: "\u30B7\u30E9\u30D0\u30B9\u304C\u6B63\u5E38\u306B\u66F4\u65B0\u3055\u308C\u307E\u3057\u305F\u3002"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @syllabus.destroy
    redirect_to university_path(@university), notice: "\u30B7\u30E9\u30D0\u30B9\u304C\u6B63\u5E38\u306B\u524A\u9664\u3055\u308C\u307E\u3057\u305F\u3002"
  end

  def search
    @universities = University.all.order(:name)
    @q = Syllabus.ransack(params[:q])
    @syllabuses = @q.result.includes(:university).page(params[:page]).per(12)
  end

  # @description シラバス情報を自動取得するアクション
  def scrape
    url = params[:url]

    unless url.present?
      render json: { error: "URL\u304C\u6307\u5B9A\u3055\u308C\u3066\u3044\u307E\u305B\u3093" }, status: :bad_request
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
