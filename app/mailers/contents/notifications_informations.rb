class NotificationsInformations
  attr_reader :user, :notifications

  def initialize(user, notifications)
    @user          = user
    @notifications = notifications.map do |notification|
      NotificationInformations.new(notification)
    end
  end

  def username
    user.email
  end

  def subject
    I18n.t('mailer.notifications_informations.subject', count: notifications.count)
  end
end
