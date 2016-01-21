class ApplicationMailer < ActionMailer::Base
  DEFAULT_EMAIL_SIGNATURE = 'notifications@deckie.io'

  default from:     DEFAULT_EMAIL_SIGNATURE
  default reply_to: DEFAULT_EMAIL_SIGNATURE
end
