class ApplicationMailer < ActionMailer::Base
  include Devise::Mailers::Helpers

  DEFAULT_EMAIL_SIGNATURE = 'notifications@deckie.io'

  default from:     DEFAULT_EMAIL_SIGNATURE
  default reply_to: 'no-reply'

  private

  def send_mail(user, type)
    if type == :reset_password_instructions
      devise_mail(user, type)
    else
      mail(to: user.email, subject: I18n.t("mailer.#{type}.subject"))
    end
  end
end
