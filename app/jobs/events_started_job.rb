class EventsStartedJob < ApplicationJob
  queue_as :default

  def perform
    Event.opened(false).with_submissions.each do |event|
      CancelSubmission.for(event.pending_submissions, reason: :remove_start)
    end
    Event.reindex!
  end
end
