class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include SessionsHelper

  private

  def require_login
    unless logged_in?
      flash[:alert] = "\u30ED\u30B0\u30A4\u30F3\u304C\u5FC5\u8981\u3067\u3059"
      redirect_to login_path
    end
  end
end
