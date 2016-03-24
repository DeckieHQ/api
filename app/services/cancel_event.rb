class CancelEvent
  def self.for(actor, events)
    events.map { |event| new(actor, event) }
  end

  def initialize(actor, event)
    @actor = actor
    @event = event
  end

  def call
    event.destroy

    AfterDestroyEventJob.perform_later(event, action)
  end

  private

  attr_reader :actor, :event

  def action
    @action ||= Action.create(actor: actor, resource: event, type: :cancel)
  end
end
