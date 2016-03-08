class CancelSubmission
  def initialize(submission)
    @submission = submission
  end

  def call
    submission.destroy
  end

  private

  attr_reader :submission
end
