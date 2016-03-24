class Preferences
  include ActiveModel::Validations
  include ActiveModel::Serialization

  SUPPORTED_NOTIFICATIONS ||= %w(event-update event-subscribe)

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
    notifications.tap(&:uniq!).each do |notification|
      unless SUPPORTED_NOTIFICATIONS.include?(notification)
        errors.add(:notifications, :unsupported, accept: SUPPORTED_NOTIFICATIONS)
      end
    end
  end
end
