class ChangeEventInfos
  def initialize(actor, event)
    @actor = actor
    @event = event
  end

  def call(params)
    if event.update(params)
      Action.create(actor: actor, resource: event, type: :update)

      confirm_pending_submissions if event.switched_to_auto_accept?
    end
    event
  end

  private

  attr_reader :actor, :event

  def confirm_pending_submissions
    ConfirmSubmission.for(event.max_confirmable_submissions).each(&:call)
  end
end
