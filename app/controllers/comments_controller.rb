class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_syllabus
  before_action :set_comment, only: [ :show, :edit, :update, :destroy ]
  before_action :validate_reply_creation, only: [ :create ], if: -> { params[:comment][:parent_id].present? }

  def index
    @comments = @syllabus.comments.includes(:user, :attachments, :replies)

    case params[:type]
    when "review"
      @comments = @comments.reviews
    when "file_share"
      @comments = @comments.file_shares.top_level
    when "chat"
      @comments = @comments.chats.top_level
    else
      @comments = @comments.top_level
    end

    @comments = @comments.order(created_at: :desc).page(params[:page]).per(20)
    @comment = Comment.new
    @active_tab = params[:type] || "review"
  end

  def show
    redirect_to university_syllabus_comments_path(@university, @syllabus, type: @comment.comment_type)
  end

  def create
    @comment = @syllabus.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      handle_file_uploads if params[:files].present?
      broadcast_comment if @comment.chat?

      flash[:notice] = "\u30B3\u30E1\u30F3\u30C8\u3092\u6295\u7A3F\u3057\u307E\u3057\u305F"

      # リファラーがシラバス詳細ページの場合はそこにリダイレクト
      if request.referer&.include?("syllabuses") && !request.referer&.include?("comments")
        redirect_to university_syllabus_path(@university, @syllabus, type: @comment.comment_type)
      else
        redirect_to university_syllabus_comments_path(@university, @syllabus, type: @comment.comment_type)
      end
    else
      @comments = @syllabus.comments.includes(:user, :attachments, :replies)
                           .top_level.order(created_at: :desc)
      @active_tab = @comment.comment_type || "review"

      flash.now[:alert] = @comment.errors.full_messages.join(", ")

      # リファラーがシラバス詳細ページの場合
      if request.referer&.include?("syllabuses") && !request.referer&.include?("comments")
        redirect_to university_syllabus_path(@university, @syllabus, type: @active_tab), alert: @comment.errors.full_messages.join(", ")
      else
        render :index, status: :unprocessable_entity
      end
    end
  end

  def edit
    unless can_edit_comment?
      flash[:alert] = "\u7DE8\u96C6\u6A29\u9650\u304C\u3042\u308A\u307E\u305B\u3093"
      redirect_to university_syllabus_comments_path(@university, @syllabus, type: @comment.comment_type)
      nil
    end
  end

  def update
    unless can_edit_comment?
      flash[:alert] = "\u7DE8\u96C6\u6A29\u9650\u304C\u3042\u308A\u307E\u305B\u3093"
      redirect_to university_syllabus_comments_path(@university, @syllabus, type: @comment.comment_type)
      return
    end

    # レビューコメントのratingは編集不可
    permitted_params = comment_params.except(:comment_type)
    permitted_params = permitted_params.except(:rating) if @comment.review?

    if @comment.update(permitted_params)
      @comment.update(edited_at: Time.current)
      flash[:notice] = "\u30B3\u30E1\u30F3\u30C8\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
      redirect_to university_syllabus_comments_path(@university, @syllabus, type: @comment.comment_type)
    else
      flash.now[:alert] = @comment.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless can_delete_comment?
      flash[:alert] = "\u524A\u9664\u6A29\u9650\u304C\u3042\u308A\u307E\u305B\u3093"
      redirect_to university_syllabus_comments_path(@university, @syllabus, type: @comment.comment_type)
      return
    end

    comment_type = @comment.comment_type
    @comment.destroy

    flash[:notice] = "\u30B3\u30E1\u30F3\u30C8\u3092\u524A\u9664\u3057\u307E\u3057\u305F"
    redirect_to university_syllabus_comments_path(@university, @syllabus, type: comment_type)
  end

  private

  def set_syllabus
    @university = University.find(params[:university_id])
    @syllabus = @university.syllabuses.find(params[:syllabus_id])
  end

  def set_comment
    @comment = @syllabus.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :comment_type, :rating, :is_anonymous, :parent_id)
  end

  def validate_reply_creation
    parent_comment = Comment.find(params[:comment][:parent_id])
    if parent_comment.review?
      flash[:alert] = "\u30EC\u30D3\u30E5\u30FC\u30B3\u30E1\u30F3\u30C8\u306B\u306F\u8FD4\u4FE1\u3067\u304D\u307E\u305B\u3093"
      redirect_to university_syllabus_comments_path(@university, @syllabus, type: "review")
      false
    end
  end

  def handle_file_uploads
    return unless params[:files].present?

    params[:files].each do |file|
      @comment.attachments.create!(file: file)
    end
  end

  def broadcast_comment
    ActionCable.server.broadcast("syllabus_#{@syllabus.id}_chat", {
      comment: @comment.as_json(include: [ :user, :attachments ]),
      user: @comment.user.as_json(only: [ :id, :name ])
    })
  end

  def can_edit_comment?
    @comment.user == current_user
  end

  def can_delete_comment?
    @comment.user == current_user || current_user&.admin?
  end
end
