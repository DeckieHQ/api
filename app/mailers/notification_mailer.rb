class NotificationMailer < ApplicationMailer
  def informations(notification)
    @content = NotificationInformations.new(notification)

    send_mail(notification.user)
  end
end
