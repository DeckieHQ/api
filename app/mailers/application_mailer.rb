class ApplicationMailer < ActionMailer::Base
  include Devise::Mailers::Helpers

  DEFAULT_EMAIL_SIGNATURE = 'notifications@deckie.io'

  default from:     DEFAULT_EMAIL_SIGNATURE
  default reply_to: 'no-reply'

  private

  def send_mail(user, type)
    change_locale_for(user) do
      mail(to: user.email, subject: I18n.t("mailer.#{type}.subject"))
    end
  end

  def change_locale_for(user)
    I18n.locale = user.culture

    yield

    I18n.locale = :en
  end
end
