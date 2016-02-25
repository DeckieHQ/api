class EventService
  include ActiveModel::Validations

  validate :event_must_have_room, on: :subscribe

  validate :event_must_be_open, on: [:subscribe, :update, :destroy]

  def initialize(event)
    @event = event
  end

  def subscribe(profile)
    return unless valid?(:subscribe)

    return if already_has_subscriber?(profile)

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
    return false unless valid?(:update)

    @errors = event.errors and return false unless event.update(params)

    process_changes

    true
  end

  def destroy
    return false unless valid?(:destroy)

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

  def event_must_have_room
    errors.add(:base, :event_full) if event.full?
  end

  def event_must_be_open
    errors.add(:base, :event_closed) if event.closed?
  end

  def already_has_subscriber?(profile)
    if event.subscriptions.find_by(profile: profile)
      return errors.add(:base, :subscriber_already_exist)
    end
  end
end
