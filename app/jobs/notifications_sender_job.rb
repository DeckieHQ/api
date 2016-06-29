class NotificationsSenderJob < ApplicationJob
  queue_as :scheduler

  def perform
    User.all.each do |user|
      if user.notifications_to_send.count > 0
        UserMailer
        .notifications_informations(user, user.notifications_to_send)
        .deliver_now
      end
      user.notifications.update_all(sent: true)
    end
  end
end
