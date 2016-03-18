class CleanAccount
  def initialize(account)
    @account = account
  end

  def call
    CancelResourceWithAction.for(resources_with_action).each(&:call)
  end

  private

  def resources_with_action
    [].concat(account.opened_hosted_events).concat(account.opened_submissions)
  end

  attr_reader :account
end
