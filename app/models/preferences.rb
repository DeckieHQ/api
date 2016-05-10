class Preferences
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attr_accessor :notifications

  validate :notifications_must_be_supported

  def initialize(attributes = {})
    @notifications = attributes[:notifications]
  end

  def attributes
    instance_values.slice('notifications')
  end

  private

  def notifications_must_be_supported
    notifications.tap(&:uniq!).each do |notification_type|
      unless Notification.types.include?(notification_type)
        errors.add(:notifications, :unsupported, accept: Notification.types)
      end
    end
  end
end
