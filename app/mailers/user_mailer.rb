class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(token: @user.verification_token)
    
    mail(
      to: @user.email,
      subject: 'メールアドレスの認証をお願いします'
    )
  end
end 