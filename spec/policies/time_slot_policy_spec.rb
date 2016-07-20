require 'rails_helper'

RSpec.describe TimeSlotPolicy do
  subject { described_class.new(user, time_slot) }

  let(:time_slot) { FactoryGirl.create(:time_slot) }

  context 'being a visitor' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:confirm) }

    it { is_expected.to forbid_action(:destroy) }

    it { is_expected.to permit_action(:join) }


    context 'when user already submited to this time slot' do
      before { time_slot.members << user.profile }

      it { is_expected.to forbid_action(:join) }

      it do
        is_expected.to have_authorization_error(:time_slot_submission_already_exist, on: :join)
      end
    end

    context 'when time slot is full' do
      let(:time_slot) { FactoryGirl.create(:time_slot, :full) }

      it { is_expected.to forbid_action(:join) }

      it do
        is_expected.to have_authorization_error(:time_slot_full, on: :join)
      end
    end
  end

  context 'being the time slot event host' do
    let(:user) { time_slot.event.host.user }

    it { is_expected.to permit_action(:confirm) }

    it { is_expected.to permit_action(:destroy) }

    it { is_expected.to forbid_action(:join) }

    context 'when time slot is closed' do
      let(:time_slot) { FactoryGirl.create(:time_slot, :closed) }

      it { is_expected.to forbid_action(:confirm) }

      it do
        is_expected.to have_authorization_error(:time_slot_closed, on: :confirm)
      end
    end
  end
end
