class CancelSubmission < ActionService
  def self.for(submissions, reason: :quit)
    submissions.map { |submission| new(submission).call(reason) }
  end

  def initialize(submission)
    super(submission.profile, submission.event)

    @submission = submission
  end

  def call(reason = :quit)
    create_action_according_to_reason(reason)

    submission.destroy
  end

  private

  attr_reader :submission

  delegate :event, to: :submission

  def create_action_according_to_reason(reason)
    return create_action(reason)    unless reason == :quit
    return create_action(:unsubmit) unless submission.confirmed?

    create_action(:leave)
    create_action(:not_ready) if event.just_ready?
  end
end
