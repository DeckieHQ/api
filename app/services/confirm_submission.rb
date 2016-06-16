class ConfirmSubmission < ActionService
  def self.for(submissions)
    submissions.map { |submission| new(submission).call }
  end

  def initialize(submission)
    super(submission.profile, submission.event)

    @submission = submission
  end

  def call
    submission.confirmed!

    create_action(:join)

    create_action(:ready) if event.just_ready?

    remove_pending_submissions if event.full?

    submission
  end

  private

  attr_reader :submission

  delegate :event, to: :submission

  def remove_pending_submissions
    CancelSubmission.for(event.pending_submissions, reason: :remove_full)
  end
end
