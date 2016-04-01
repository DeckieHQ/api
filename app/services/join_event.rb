class JoinEvent < ActionService
  attr_reader :new_submission

  def initialize(profile, event)
    super(profile, event)

    @new_submission = Submission.new(event: event, profile: profile)
  end

  def call
    if event.auto_accept?
      confirm_new_submission!
    else
      new_submission.pending!

      create_action(:subscribe)
    end
    new_submission
  end

  private

  alias_method :event, :resource

  def confirm_new_submission!
    ConfirmSubmission.new(new_submission).call
  end
end
