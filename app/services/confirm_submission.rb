class ConfirmSubmission
  delegate :event, to: :submission

  def self.for(submissions)
    submissions.map { |submission| new(submission) }
  end

  def initialize(submission)
    @submission = submission
  end

  def call
    submission.confirmed!

    Action.create(actor: submission.profile, resource: event, type: :join)

    destroy_pending_submissions if event.full?

    submission
  end

  protected

  attr_reader :submission

  def destroy_pending_submissions
    Action.create(actor: event.host, resource: event, type: :full)

    event.destroy_pending_submissions
  end
end
