require 'rails_helper'

RSpec.describe ConfirmSubscription do
  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  let(:service) { ConfirmSubscription.new(subscription) }

  let(:subscription) do
    event.pending_subscriptions.first
  end

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it 'returns the subscription' do
      is_expected.to eq(subscription)
    end

    it 'confirms the subscription' do
      expect(subscription).to be_confirmed
    end

    context 'when event has one slot remaining' do
      let(:event) do
        FactoryGirl.create(:event_with_one_slot_remaining, :with_pending_subscriptions)
      end

      it 'removes the pending subscriptions' do
        expect(event.pending_subscriptions).to be_empty
      end

      it "doesn't remove the other subscriptions" do
        expect(event.subscriptions).to_not be_empty
      end
    end
  end
end
