class ConfirmSubmission
  def initialize(submission)
    @submission = submission
    @event      = submission.event
  end

  def call
    submission.confirmed!

    destroy_pending_submissions if event.full?

    submission
  end

  private

  attr_reader :submission, :event

  # TODO: send notification to removed submissions.
  def destroy_pending_submissions
    event.pending_submissions.destroy_all
  end
end
