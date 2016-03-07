require 'rails_helper'

RSpec.describe SubscribeEvent do
  let(:service) { SubscribeEvent.new(user, event) }

  let(:user) { FactoryGirl.create(:user) }

  let(:event) { FactoryGirl.create(:event) }

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it 'saves and return the subscription' do
      is_expected.to be_persisted
    end

    it 'links the subscription to both event and profile' do
      is_expected.to have_attributes(
        profile_id: user.profile.id, event_id: event.id
      )
    end

    it 'returns the pending subscription' do
      is_expected.to be_pending
    end

    context 'when event has auto_accept' do
      let(:event) { FactoryGirl.create(:event, :auto_accept) }

      it 'confirms and return the subscription' do
        is_expected.to be_confirmed
      end
    end
  end
end