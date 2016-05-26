class FeedbackInformations < SimpleDelegator
  def subject
    I18n.t('mailer.feedback_informations.subject', title: title)
  end
end
