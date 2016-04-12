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

    remove_pending_submissions if submission.event.full?

    submission
  end

  private

  attr_reader :submission

  def remove_pending_submissions
    CancelSubmission.for(submission.event.pending_submissions, reason: :remove_full)
  end
end
