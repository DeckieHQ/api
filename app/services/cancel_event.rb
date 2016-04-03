class CancelEvent < ActionService
  def self.for(profile, events)
    events.map { |event| new(profile, event).call }
  end

  def call
    create_action(:cancel)

    event.destroy
  end

  private

  alias_method :event, :resource
end
