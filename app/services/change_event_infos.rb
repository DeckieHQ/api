class ChangeEventInfos < ActionService
  def call(params)
    if event.update(params)
      create_action(:update)

      confirm_pending_submissions if event.switched_to_auto_accept?
    end
    event
  end

  private

  alias_method :event, :resource

  def confirm_pending_submissions
    ConfirmSubmission.for(event.max_confirmable_submissions)
  end
end
