class SubscriptionService
  def initialize(subscription)
    @subscription = subscription
  end

  def confirm
    subscription.confirmed!

    destroy_pending_subscriptions if event.full?

    true
  end

  def destroy
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
end
