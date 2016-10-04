class CancelEvent < ActionService
  def self.for(profile, events)
    events.map { |event| new(profile, event).call }
  end

  def call
    create_action(:cancel)

    self.class.for(actor, event.children)

    event.destroy
  end

  private

  alias_method :event, :resource
end
