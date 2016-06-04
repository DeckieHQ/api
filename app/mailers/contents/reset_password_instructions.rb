class ResetPasswordInstructions < SimpleDelegator
  def initialize(user, token)
    super(user)

    @token = token
  end

  def username
    email
  end

  def subject
    I18n.t('mailer.reset_password_instructions.subject')
  end

  def reset_password_url
    UrlHelpers.front_for('reset-password', params: { token: token })
  end

  private

  attr_reader :token
end
