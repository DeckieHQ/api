class EventService
  attr_reader :errors

  def initialize(event)
    @event  = event
  end

  def subscribe(profile)
    subscription = Subscription.create(
      event: event, profile: profile, status: :pending
    )
    # Using the subscription service is mandatory to automatically send
    # notifications to event's attendees on success.
    SubscriptionService.new(subscription).confirm if event.auto_accept?

    # TODO: Send notification to host regardless of the status.
    subscription
  end

  def update(params)
    @errors = event.errors and return false unless event.update(params)

    process_changes

    true
  end

  def destroy
    event.destroy
  end

  private

  attr_reader :event

  def process_changes
    auto_accept_was, auto_accept = event.previous_changes['auto_accept']

    return if !auto_accept || auto_accept_was

    event.subscriptions.take(
      event.capacity - event.attendees_count
    ).each do |subscription|
      SubscriptionService.new(subscription).confirm
    end
  end
end
