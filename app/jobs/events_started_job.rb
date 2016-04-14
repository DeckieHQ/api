class EventsStartedJob < ApplicationJob
  queue_as :scheduler

  def perform
    Event.opened(false).with_pending_submissions.each do |event|
      CancelSubmission.for(event.pending_submissions, reason: :remove_start)
    end
  end
end
