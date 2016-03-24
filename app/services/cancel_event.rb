class CancelEvent
  def self.for(actor, events)
    events.map { |event| new(actor, event) }
  end

  def initialize(actor, event)
    @actor = actor
    @event = event
  end

  def call
    Action.create(actor: actor, resource: event, type: :cancel)

    event.destroy
  end

  private

  attr_reader :actor, :event
end
