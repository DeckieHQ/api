class CleanAccount
  def initialize(account)
    @account = account
  end

  def call
    CancelEvent.for(account.profile, account.opened_hosted_events)

    CancelSubmission.for(account.opened_submissions)

    CancelTimeSlotSubmission.for(account.time_slot_submissions)
  end

  private

  attr_reader :account
end
