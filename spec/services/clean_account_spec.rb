require 'rails_helper'

RSpec.describe CleanAccount do
  let(:account) do
    instance_double('User', profile: double(),
      opened_hosted_events: Array.new(5),
      opened_submissions:   Array.new(3)
    )
  end

  let(:service) { CleanAccount.new(account) }

  describe '#call' do
    before do
      allow(CancelEvent).to      receive(:for)
      allow(CancelSubmission).to receive(:for)

      service.call
    end

    it 'cancels each user opened hosted events' do
      expect(CancelEvent).to have_received(:for).with(
        account.profile, account.opened_hosted_events
      )
    end

    it 'cancels each user opened subsmissions' do
      expect(CancelSubmission).to have_received(:for).with(account.opened_submissions)
    end
  end
end
