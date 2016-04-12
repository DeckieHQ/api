class JoinEvent < ActionService
  def initialize(profile, event)
    super(profile, event)

    @new_submission = Submission.new(event: event, profile: profile)
  end

  def call
    if event.auto_accept?
      confirm_new_submission!
    else
      create_action(:submit)

      new_submission.tap(&:pending!)
    end
  end

  private

  alias_method :event, :resource

  attr_reader :new_submission

  def confirm_new_submission!
    ConfirmSubmission.new(new_submission).call
  end
end
