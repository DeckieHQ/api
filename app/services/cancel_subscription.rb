class CancelSubscription
  def initialize(subscription)
    @subscription = subscription
  end

  def call
    subscription.destroy
  end

  private

  attr_reader :subscription
end
