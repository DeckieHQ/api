class Preferences
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attr_accessor :notifications

  validate :notifications_must_be_supported

  def initialize(attributes = {})
    @notifications = attributes['notifications']
  end

  def attributes
    instance_values.slice('notifications')
  end

  private

  def notifications_must_be_supported
    return add_notifications_error unless notifications.kind_of?(Array)

    notifications.tap(&:uniq!).each do |notification_type|
      add_notifications_error unless Notification.types.include?(notification_type)
    end
  end

  def add_notifications_error
    errors.add(:notifications, :unsupported, accept: Notification.types)
  end
end
