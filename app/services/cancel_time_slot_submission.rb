class CancelTimeSlotSubmission < ActionService
  def self.for(submissions)
    submissions.map { |submission| new(submission).call }
  end

  def initialize(submission)
    super(submission.profile, submission.time_slot)

    @submission = submission
  end

  def call
  #  create_action(:unsubmit)

    submission.destroy
  end

  private

  attr_reader :submission
end
