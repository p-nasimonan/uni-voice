class UsersController < ApplicationController
  before_action :require_login, except: [ :new, :create ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in(@user)
      redirect_to root_path, notice: "\u30A2\u30AB\u30A6\u30F3\u30C8\u3092\u4F5C\u6210\u3057\u307E\u3057\u305F"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params_for_update)
      redirect_to @user, notice: "\u30D7\u30ED\u30D5\u30A3\u30FC\u30EB\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: "\u30A2\u30AB\u30A6\u30F3\u30C8\u3092\u524A\u9664\u3057\u307E\u3057\u305F"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end

  def user_params_for_update
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
