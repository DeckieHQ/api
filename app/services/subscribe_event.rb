class SubscribeEvent
  def initialize(user, event)
    @user  = user
    @event = event
  end

  def call
    # Using the subscription service is mandatory to automatically send
    # notifications to event's attendees on success.
    ConfirmSubscription.new(new_subscribtion).call if event.auto_accept?

    # TODO: Send notification to host regardless of the status.
    new_subscribtion
  end

  private

  attr_reader :user, :event

  def new_subscribtion
    @new_subscribtion ||= Subscription.create(
      event: event, profile: user.profile, status: :pending
    )
  end
end
