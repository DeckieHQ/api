class EmailVerificationInstructions
  def initialize(user)
    @user = user
  end

  def username
    user.email
  end

  def email_verification_url
    UrlHelpers.front_for(
      :verify_email, params: { token: user.email_verification_token }
    )
  end

  private

  attr_reader :user
end
