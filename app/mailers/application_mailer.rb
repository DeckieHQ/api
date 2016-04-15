class ApplicationMailer < ActionMailer::Base
  private

  attr_reader :content

  def send_mail(user)
    change_locale_for(user) do
      mail(to: user.email, subject: content.subject)
    end
  end

  def change_locale_for(user)
    I18n.locale = user.culture

    yield

    I18n.locale = :en
  end
end
