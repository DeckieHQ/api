class UserMailer < ApplicationMailer
  def welcome_informations(user)
    @content = WelcomeInformations.new(user)

    send_mail(user)
  end

  def reset_password_instructions(user, token, _opts={})
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

  def flexible_event_reminder(user, event)
    @content = FlexibleEventReminder.new(user, event)

    send_mail(user)
  end
end
