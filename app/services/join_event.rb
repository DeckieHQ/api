class JoinEvent
  def initialize(user, event)
    @user  = user
    @event = event
  end

  def call
    # Using the submission service is mandatory to automatically send
    # notifications to event's attendees on success.
    confirm_new_submission if event.auto_accept?

    # TODO: Send notification to host regardless of the status.
    new_submission
  end

  private

  attr_reader :user, :event

  def new_submission
    @new_submission ||= Submission.create(
      event: event, profile: user.profile, status: :pending
    )
  end

  def confirm_new_submission
    ConfirmSubmission.new(new_submission).call
  end
end
