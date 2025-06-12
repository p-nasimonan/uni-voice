class EmailVerificationsController < ApplicationController
  def create
    @user = User.find_by(email: params[:email])
    
    if @user
      # 認証トークンを生成
      token = SecureRandom.hex(20)
      @user.update(verification_token: token, verification_sent_at: Time.current)
      
      # 認証メールを送信
      UserMailer.verification_email(@user).deliver_later
      
      redirect_to root_path, notice: '認証メールを送信しました。メールをご確認ください。'
    else
      redirect_to new_user_registration_path, alert: 'メールアドレスが見つかりません。'
    end
  end

  def verify
    @user = User.find_by(verification_token: params[:token])
    
    if @user && @user.verification_sent_at > 24.hours.ago
      @user.update(verified: true, verification_token: nil)
      redirect_to root_path, notice: 'メールアドレスが認証されました。'
    else
      redirect_to root_path, alert: '認証リンクが無効または期限切れです。'
    end
  end
end 