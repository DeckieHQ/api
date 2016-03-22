class CleanAccount
  def initialize(account)
    @account = account
  end

  def call
    CancelEvent.for(account, account.opened_hosted_events).each(&:call)

    CancelSubmission.for(account.opened_submissions).each(&:call)
  end

  protected

  attr_reader :account
end
