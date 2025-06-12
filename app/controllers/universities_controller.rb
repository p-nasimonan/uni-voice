class UniversitiesController < ApplicationController
  def index
    @universities = University.all.order(name: :asc)
  end

  def show
    @university = University.find(params[:id])
    @syllabuses = @university.syllabuses.order(created_at: :desc)
  end

  def new
    @university = University.new
  end

  def create
    @university = University.new(university_params)
    if @university.save
      redirect_to @university, notice: '大学が正常に登録されました。'
    else
      render :new
    end
  end

  def edit
    @university = University.find(params[:id])
  end

  def update
    @university = University.find(params[:id])
    if @university.update(university_params)
      redirect_to @university, notice: '大学情報が正常に更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @university = University.find(params[:id])
    @university.destroy
    redirect_to universities_path, notice: '大学が正常に削除されました。'
  end

  private

  def university_params
    params.require(:university).permit(:name, :email_domain)
  end
end
