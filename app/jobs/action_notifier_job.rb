class ActionNotifier
  def initialize(action)
    @action = action
  end

  def notify
    Notification.transaction do
      users.each do |user|
        Notification.create(action: action, user: user).send_email
      end
    end
  end

  private

  attr_reader :action

  def users
    @users ||= User.joins(:profile).where(profiles: { id: action.receivers_ids })
  end
end

class ActionNotifierJob < ApplicationJob
  queue_as :notifications

  def perform(action)
    ActionNotifier.new(action).notify
  end
end
