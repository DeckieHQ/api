class AccountService
  def initialize(user)
    @user = user
  end

  def cleanup
    destroy_opened_hosted_events
    destroy_subscriptions_to_opened_events
  end

  private

  attr_reader :user

  def destroy_opened_hosted_events
    user.hosted_events.opened.destroy_all
  end

  def destroy_subscriptions_to_opened_events
    user.subscriptions.filter({ event: :opened }).destroy_all
  end
end
