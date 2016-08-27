class EmailVerificationInstructions < SimpleDelegator
  def username
    display_name
  end

  def subject
    I18n.t('mailer.email_verification_instructions.subject')
  end

  def email_verification_url
    UrlHelpers.front_for(
      'email-verification', params: { token: email_verification_token }
    )
  end
end
