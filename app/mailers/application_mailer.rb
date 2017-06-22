class ApplicationMailer < ActionMailer::Base
  private

  attr_reader :content

  def send_mail(user)
    I18n.with_locale(user.culture) do
      mail(to: user.email, subject: content.subject)
    end
  end

end
