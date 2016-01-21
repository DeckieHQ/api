class UserMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def reset_password_instructions(user, token, opts={})
    @reset_password_url = users_reset_password_url
    @reset_password_url << "/edit?reset_password_token=#{token}"

    devise_mail(user, :reset_password_instructions)
  end
end
