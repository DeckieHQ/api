class WelcomeInformations < SimpleDelegator
  def subject
    I18n.t('mailer.welcome_informations.subject')
  end

  def details
    I18n.t('mailer.welcome_informations.details').gsub("\n", '<br><br>')
  end

  def search_url
    UrlHelpers.front_for('search')
  end
end
