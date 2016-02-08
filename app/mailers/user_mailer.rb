class UserMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def reset_password_instructions(user, token, opts={})
    @reset_password_url = front_link_for(
      action: :password, path: '/edit',
      params: { reset_password_token: token }
    )
    devise_mail(user, :reset_password_instructions)
  end

  def email_verification_instructions(user)
    @user = user
    @email_verification_url = front_link_for(
      action: :verifications, path: '/email',
      params: { token: user.email_verification_token }
    )
    mail to: user.email, subject: I18n.t('verifications.email.subject')
  end

  private

  def front_link_for(action:, path: '', params:)
    send("user_#{action}_url") << "#{path}?#{params.to_query}"
  end
end
