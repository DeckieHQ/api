class ReindexEventsJob < ApplicationJob
  queue_as :scheduler

  def perform
    Event.reindex!
  end
end
