class ActionNotifierJob < ApplicationJob
  queue_as :default

  def perform(action)
    ActionNotifier.new(action).notify
  end
end
