class ConfirmSubmission < ActionService
  def self.for(submissions)
    submissions.map { |submission| new(submission) }
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
    EventReady.new(submission.event).call(:full)
  end
end
