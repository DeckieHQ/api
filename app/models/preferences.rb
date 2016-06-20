class Preferences
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attr_accessor :notifications, :user

  delegate :id, to: :user

  validate :notifications_must_be_supported

  def self.for(user)
    new({ 'user' => user }.merge(user.preferences))
  end

  def initialize(params = {})
    @user = params['user']

    merge_params(params)
  end

  def attributes
    instance_values.slice('notifications')
  end

  def update(params = {})
    merge_params(params)

    valid? && user.update(preferences: attributes)
  end

  private

  def merge_params(params)
    @notifications = params['notifications']
  end

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
