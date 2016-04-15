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
