class CancelSubmission
  def self.for(submissions)
    submissions.map { |submission| new(submission) }
  end

  def initialize(submission)
    @submission = submission
  end

  def call
    Action.create(
      actor: submission.profile, resource: submission.event, type: action_type
    )
    submission.destroy
  end

  private

  attr_reader :submission

  def action_type
    submission.confirmed? ? :leave : :unsubscribe
  end
end
