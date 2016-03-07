require 'rails_helper'

RSpec.describe CancelSubscription do
  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  let(:service) { CancelSubscription.new(subscription) }

  let(:subscription) { event.subscriptions.last }

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it { is_expected.to be_truthy }

    it 'destroys the subscription' do
      expect(subscription).to_not be_persisted
    end
  end
end
