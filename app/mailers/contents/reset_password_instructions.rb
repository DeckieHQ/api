class ResetPasswordInstructions
  def initialize(user, token)
    @user  = user
    @token = token
  end

  def username
    user.email
  end

  def reset_password_url
    UrlHelpers.front_for(:edit_password, params: { token: token })
  end

  private

  attr_reader :user, :token
end
