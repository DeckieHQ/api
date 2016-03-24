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
    submission
  end

  private

  attr_reader :submission
end
