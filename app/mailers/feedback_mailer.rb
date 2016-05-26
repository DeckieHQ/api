class FeedbackMailer < ApplicationMailer
  def informations(feedback)
    @content = FeedbackInformations.new(feedback)

    mail(to: receiver, subject: content.subject)
  end

  private

  def receiver
    Rails.application.config.action_mailer.default_options[:from]
  end
end
