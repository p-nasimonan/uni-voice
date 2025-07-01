module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def require_login
    unless logged_in?
      flash[:alert] = "\u30ED\u30B0\u30A4\u30F3\u304C\u5FC5\u8981\u3067\u3059"
      redirect_to login_path
    end
  end
end
