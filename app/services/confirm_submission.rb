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

    Action.create(notify: :later,
      actor: submission.profile, resource: event, type: :join
    )
    remove_pending_submissions if event.full?

    submission
  end

  private

  attr_reader :submission

  def remove_pending_submissions
    EventReady.new(event).call(:full)
  end
end
