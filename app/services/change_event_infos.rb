class ChangeEventInfos
  def initialize(event)
    @event = event
  end

  def call(params)
    if event.update(params) && switched_to_auto_accept?
      confirm_pending_submissions
    end
    event
  end

  private

  attr_reader :event

  def switched_to_auto_accept?
    auto_accept_was, auto_accept = event.previous_changes['auto_accept']

    auto_accept && !auto_accept_was
  end

  def confirm_pending_submissions
    event.pending_submissions.take(
      event.capacity - event.attendees_count
    ).each do |submission|
      ConfirmSubmission.new(submission).call
    end
  end
end
