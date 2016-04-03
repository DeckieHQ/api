class CancelSubmission < ActionService
  def self.for(submissions)
    submissions.map { |submission| new(submission).call }
  end

  def initialize(submission)
    super(submission.profile, submission.event)

    @submission = submission
  end

  def call
    create_action(submission.confirmed? ? :leave : :unsubscribe)

    submission.destroy
  end

  private

  attr_reader :submission
end
