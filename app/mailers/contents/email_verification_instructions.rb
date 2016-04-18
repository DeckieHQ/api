class EmailVerificationInstructions < SimpleDelegator
  def username
    email
  end

  def subject
    I18n.t('mailer.email_verification_instructions.subject')
  end

  def email_verification_url
    UrlHelpers.front_for(
      :verify_email, params: { token: email_verification_token }
    )
  end
end
