class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in(user)
      redirect_to root_path, notice: "\u30ED\u30B0\u30A4\u30F3\u3057\u307E\u3057\u305F"
    else
      flash.now[:alert] = "\u30E1\u30FC\u30EB\u30A2\u30C9\u30EC\u30B9\u307E\u305F\u306F\u30D1\u30B9\u30EF\u30FC\u30C9\u304C\u6B63\u3057\u304F\u3042\u308A\u307E\u305B\u3093"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: "\u30ED\u30B0\u30A2\u30A6\u30C8\u3057\u307E\u3057\u305F"
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
