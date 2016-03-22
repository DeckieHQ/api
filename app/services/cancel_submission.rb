class CancelSubmission
  def self.for(submissions)
    submissions.map { |submission| new(submission) }
  end

  def initialize(submission)
    @submission = submission
  end

  def call
    if submission.confirmed?
      Action.create(
        actor: submission.profile, resource: submission.event, type: :leave
      )
    end
    submission.destroy
  end

  protected

  attr_reader :submission
end
