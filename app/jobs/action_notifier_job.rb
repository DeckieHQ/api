class ActionNotifier
  def initialize(action)
    @action = action
  end

  def notify
    Notification.transaction do
      users.each do |user|
        Notification.create(action: action, user: user)
      end
    end
  end

  private

  attr_reader :action

  def users
    @users ||= Profile.where(id: action.receiver_ids).includes(:user).map(&:user)
  end
end

class ActionNotifierJob < ApplicationJob
  queue_as :notifications

  def perform(action)
    ActionNotifier.new(action).notify
  end
end
