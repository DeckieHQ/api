require 'rails_helper'

RSpec.describe EventService, :type => :service do
  let(:service) { EventService.new(event) }

  describe 'subscribe' do
    let(:profile) { FactoryGirl.create(:profile) }

    subject(:subscribe) { service.subscribe(profile) }

    before { subscribe }

    let(:event) { FactoryGirl.create(:event) }

    it 'saves and return the subscription' do
      is_expected.to be_persisted
    end

    it 'links the subscription to both event and profile' do
      is_expected.to have_attributes(
        profile_id: profile.id, event_id: event.id
      )
    end

    it 'returns the pending subscription' do
      is_expected.to be_pending
    end

    context 'when event has auto_accept' do
      let(:event) { FactoryGirl.create(:event, :auto_accept) }

      it 'confirms and return subscription' do
        is_expected.to be_confirmed
      end
    end
  end

  describe '#destroy' do
    let(:event) { FactoryGirl.create(:event) }

    subject(:destroy) { service.destroy }

    before { destroy }

    it { is_expected.to be_truthy }

    it 'removes the event' do
      expect(event).to_not be_persisted
    end
  end

  describe '#update' do
    let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

    let(:params) do
      FactoryGirl.build(:event).attributes.slice('title', 'description')
    end

    subject(:update) { service.update(params) }

    before { update }

    it { is_expected.to be_truthy }

    it 'updates the event' do
      expect(event.reload).to have_attributes(params)
    end

    it "doesn't confirm any subscription" do
      expect(event.subscriptions.pending).to_not be_empty
    end

    context 'when changing mode to auto_accept true' do
      let(:event) do
        capacity = Faker::Number.between(5, 10)

        FactoryGirl.create(:event, :with_pending_subscriptions,
          capacity: capacity, pendings_count: capacity * 2
        )
      end

      let(:params) { { auto_accept: true } }

      it 'accepts the maximum allowed of pending subscriptions' do
        expect(event.reload).to be_full
      end

      it 'removes the other pending subscriptions' do
        expect(event.subscriptions.pending).to be_empty
      end
    end

    context 'when changing mode to auto_accept false' do
      let(:event) { FactoryGirl.create(:event, :auto_accept, :with_pending_subscriptions) }

      let(:params) { { auto_accept: false } }

      it "doesn't confirm any subscription" do
        expect(event.subscriptions.pending).to_not be_empty
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { title: nil } }

      it { is_expected.to be_falsy }

      it 'has the validation errors' do
        expect(service.errors).to eql(event.errors)
      end
    end
  end
end
