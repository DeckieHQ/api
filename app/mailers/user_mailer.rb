class UserMailer < ApplicationMailer
  def reset_password_instructions(user, token, opts={})
    @content = ResetPasswordInstructions.new(user, token)

    send_mail(user)
  end

  def email_verification_instructions(user)
    @content = EmailVerificationInstructions.new(user)

    send_mail(user)
  end

  def notifications_informations(user, notifications)
    @content = NotificationsInformations.new(user, notifications)

    send_mail(user)
  end
end
