class WelcomeInformations < SimpleDelegator
  def username
    email
  end

  def subject
    I18n.t('mailer.welcome_informations.subject')
  end
end
