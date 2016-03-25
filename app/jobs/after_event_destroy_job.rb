class AfterEventDestroyJob < ApplicationJob
  queue_as :default

  def perform(event, action)
    ActionNotifier.new(action).notify

    AfterEventDestroy.new(event).cleanup

    #ActionNotifierJob.perform_now(action)

    #event.submissions.destroy_all
  end
end
