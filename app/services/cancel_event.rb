class CancelEvent
  def initialize(event)
    @event = event
  end

  def call
    event.destroy
  end

  private

  attr_reader :event
end
