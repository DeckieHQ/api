class ResetPasswordInstructions
  def initialize(user, token)
    @user  = user
    @token = token
  end

  def username
    user.email
  end

  def reset_password_url
    UrlHelpers.front_for(:edit_password, params: { token: token })
  end

  private

  attr_reader :user, :token
end

class EmailVerificationInstructions
  def initialize(user)
    @user = user
  end

  def username
    user.email
  end

  def email_verification_url
    UrlHelpers.front_for(
      :verify_email, params: { token: user.email_verification_token }
    )
  end

  private

  attr_reader :user
end

class UserMailer < ApplicationMailer
  def reset_password_instructions(user, token, opts={})
    @content = ResetPasswordInstructions.new(user, token)

    send_mail(user, :reset_password_instructions)
  end

  def email_verification_instructions(user)
    @content = EmailVerificationInstructions.new(user)

    send_mail(user, :email_verification_instructions)
  end
end
