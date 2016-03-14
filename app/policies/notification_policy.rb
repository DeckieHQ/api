class NotificationPolicy < ApplicationPolicy
  alias_method :notification, :record

  def show?
    notification_owner?
  end

  def view?
    notification_owner?
  end

  private

  def notification_owner?
    user == notification.user
  end
end
