class ChangeEventInfos
  def initialize(event)
    @event = event
  end

  def call(params)
    if event.update(params) && switched_to_auto_accept?
      confirm_pending_subscriptions
    end
    event
  end

  attr_reader :event

  def switched_to_auto_accept?
    auto_accept_was, auto_accept = event.previous_changes['auto_accept']

    auto_accept && !auto_accept_was
  end

  def confirm_pending_subscriptions
    event.pending_subscriptions.take(
      event.capacity - event.attendees_count
    ).each do |subscription|
      ConfirmSubscription.new(subscription).call
    end
  end
end
