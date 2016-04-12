class CancelSubmission < ActionService
  def self.for(submissions, reason: :quit)
    submissions.map { |submission| new(submission).call(reason) }
  end

  def initialize(submission)
    super(submission.profile, submission.event)

    @submission = submission
  end

  def call(reason = :quit)
    if reason == :quit
      create_action(submission.confirmed? ? :leave : :unsubmit)
    else
      create_action(reason)
    end
    submission.destroy
  end

  private

  attr_reader :submission
end
