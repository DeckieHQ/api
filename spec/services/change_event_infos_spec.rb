require 'rails_helper'

RSpec.describe ChangeEventInfos do
  let(:service) { ChangeEventInfos.new(event) }

  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  describe '#call' do
    subject(:call) { service.call(params) }

    before { call }

    let(:params) do
      FactoryGirl.build(:event).attributes.slice('title', 'description')
    end

    it 'returns the event' do
      is_expected.to eq(event)
    end

    it 'updates the event' do
      expect(event.reload).to have_attributes(params)
    end

    it "doesn't confirm any subscription" do
      expect(event.confirmed_subscriptions).to be_empty
    end

    context 'when switching to auto_accept ' do
      let(:capacity) { Faker::Number.between(1, 6) }

      # We must have non-pending subscriptions to ensure that only pending
      # subscriptions are confirmed.
      let(:event) do
        FactoryGirl.create(:event_with_subscriptions, :with_pending_subscriptions,
          capacity: capacity, subscriptions_count: capacity - 1, pendings_count: 1
        )
      end

      let(:params) { { auto_accept: true } }

      it 'accepts the maximum allowed of pending subscriptions' do
        expect(event.reload).to be_full
      end

      it 'removes the other pending subscriptions' do
        expect(event.pending_subscriptions).to be_empty
      end
    end

    context 'when switching to manual_accept' do
      let(:event) { FactoryGirl.create(:event, :auto_accept, :with_pending_subscriptions) }

      let(:params) { { auto_accept: false } }

      it "doesn't confirm any subscription" do
        expect(event.confirmed_subscriptions).to be_empty
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { title: nil } }

      it "doesn't confirm any subscription" do
        expect(event.confirmed_subscriptions).to be_empty
      end
    end
  end
end
