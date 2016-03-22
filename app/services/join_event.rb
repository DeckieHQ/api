class JoinEvent
  def initialize(profile, event)
    @profile = profile
    @event   = event
  end

  def call
    if event.auto_accept?
      confirm_new_submission
    else
      create_action
    end
    new_submission
  end

  private

  attr_reader :profile, :event

  def new_submission
    @new_submission ||= Submission.create(
      event: event, profile: profile, status: :pending
    )
  end

  def confirm_new_submission
    ConfirmSubmission.new(new_submission).call
  end

  def create_action
    Action.create(actor: profile, resource: event, type: :subscribe)
  end
end
