class EventReady
  def initialize(event)
    @event = event
  end

  def call(reason)
    Action.create(notify: :later, actor: event.host, resource: event, type: reason)

    event.destroy_pending_submissions
  end

  private

  attr_reader :event
end
