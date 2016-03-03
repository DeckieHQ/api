require 'rails_helper'

RSpec.describe SubscriptionService, :type => :service do
  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  let(:service) { SubscriptionService.new(subscription) }

  let(:subscription) do
    event.subscriptions.find_by(status: :pending)
  end

  describe '#confirm' do
    subject(:confirm) { service.confirm }

    before { confirm }

    it { is_expected.to be_truthy }

    it 'confirms the subscription' do
      expect(subscription).to be_confirmed
    end

    context 'when event has one slot remaining' do
      let(:event) do
        FactoryGirl.create(:event_with_one_slot_remaining, :with_pending_subscriptions)
      end

      it 'removes the pending subscriptions' do
        expect(event.subscriptions.pending).to be_empty
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { service.destroy }

    let!(:first_pending_subscription) do
      event.subscriptions.pending.first
    end

    let(:subscription) { event.subscriptions.last }

    before { destroy }

    it { is_expected.to be_truthy }

    it 'destroys the subscription' do
      expect(subscription).to_not be_persisted
    end
  end
end
