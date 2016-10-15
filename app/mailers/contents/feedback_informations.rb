class FeedbackInformations < SimpleDelegator
  def subject
    I18n.t('mailer.feedback_informations.subject', title: title)
  end

  def sender
    email || I18n.t('mailer.feedback_informations.default_sender')
  end
end
