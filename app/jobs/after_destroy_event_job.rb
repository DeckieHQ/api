class AfterDestroyEventJob < ApplicationJob
  queue_as :default

  def perform(event, action)
    ActionNotifier.new(action).notify

    event.submissions.destroy_all
  end
end
