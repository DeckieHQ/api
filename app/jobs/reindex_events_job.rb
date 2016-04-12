class ReindexEventsJob < ApplicationJob
  queue_as :default

  def perform
    Event.reindex!
  end
end
