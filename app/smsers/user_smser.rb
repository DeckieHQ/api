class UserSMSer < ApplicationSMSer
  def self.phone_number_verification_instructions(user)
    message = I18n.t(
      'verifications.phone_number.message',
      code: user.phone_number_verification_token
    )
    sms(to: user.phone_number, message: message)
  end
end
