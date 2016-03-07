class ConfirmSubscription
  def initialize(subscription)
    @subscription = subscription
    @event        = subscription.event
  end

  def call
    subscription.confirmed!

    destroy_pending_subscriptions if event.full?

    subscription
  end

  private

  attr_reader :subscription, :event

  # TODO: send notification to removed subscriptions.
  def destroy_pending_subscriptions
    event.pending_subscriptions.destroy_all
  end
end
