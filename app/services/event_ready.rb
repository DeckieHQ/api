class EventReady < ActionService
  def initialize(event)
    super(event.host, event)
  end

  def call(reason)
    create_action(reason)

    event.destroy_pending_submissions
  end

  private

  alias_method :event, :resource
end
