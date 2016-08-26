class NotificationsInformations
  attr_reader :user, :notifications

  def initialize(user, notifications)
    @user          = user
    @notifications = notifications.map do |notification|
      NotificationInformations.new(notification)
    end
  end

  def username
    user.display_name
  end

  def subject
    I18n.t('mailer.notifications_informations.subject')
  end

  def subscribe_url
    UrlHelpers.front_for('account/notifications')
  end
end
