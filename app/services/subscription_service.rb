class SubscriptionService
  include ActiveModel::Validations

  validate :must_be_unconfirmed, on: :confirm

  validate :event_must_have_room, on: :confirm

  validate :event_must_be_open, on: [:confirm, :destroy]

  def initialize(subscription)
    @subscription = subscription
  end

  def confirm
    return false unless valid?(:confirm)

    subscription.confirmed!

    destroy_pending_subscriptions if event.full?

    true
  end

  def destroy
    return false unless valid?(:destroy)

    subscription.destroy
  end

  private

  attr_reader :subscription

  def event
    @event ||= subscription.event
  end

  # TODO: send notification to removed subscriptions.
  def destroy_pending_subscriptions
    event.subscriptions.pending.destroy_all
  end

  def must_be_unconfirmed
    errors.add(:base, :already_confirmed) if subscription.confirmed?
  end

  def event_must_have_room
    errors.add(:base, :event_full) if event.full?
  end

  def event_must_be_open
    errors.add(:base, :event_closed) if event.closed?
  end
end
