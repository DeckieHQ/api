require 'rails_helper'

RSpec.describe ConfirmTimeSlot do
  describe '#call' do
    subject(:call) { described_class.new(profile, time_slot).call }

    let(:time_slot) { FactoryGirl.create(:time_slot, :with_members) }

    let(:profile) { FactoryGirl.create(:profile) }

    before do
      allow(JoinEvent).to receive(:for)

      call
    end

    it 'add each timeslot member to the associated event' do
      expect(JoinEvent).to have_received(:for).with(time_slot.event, time_slot.members)
    end

    it 'destroys all the event time slots' do
      expect(time_slot.event.time_slots).to be_empty
    end

    it 'transforms the event to a non flexible event' do
      expect(time_slot.event).to_not be_flexible
    end

    it 'assigns time slot begin_at to the event' do
      expect(time_slot.event.begin_at).to eq(time_slot.begin_at)
    end

    it { is_expected.to have_created_action(profile, time_slot, :confirm) }
  end
end
