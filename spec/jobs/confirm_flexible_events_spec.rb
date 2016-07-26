require 'rails_helper'

RSpec.describe ConfirmFlexibleEvents, type: :job do
  it 'uses the scheduler queue' do
    expect(described_class.queue_name).to eq('scheduler')
  end

  describe '#perform' do
    let!(:events) { FactoryGirl.create_list(:event, 5, :flexible) }

    let!(:confirmable) do
      events.shuffle.first.tap do |event|
        event.time_slots << TimeSlot.new(created_at: 2.days.ago, begin_at: Time.now + 2.hours)
      end
    end

    let!(:optimum_time_slot) { confirmable.optimum_time_slot }

    let(:confirm_service) { double(call: true) }

    before do
      allow(ConfirmTimeSlot).to receive(:new).and_call_original

      described_class.perform_now
    end

    it 'confirms the appropriate time slot' do
      expect(ConfirmTimeSlot).to have_received(:new).with(confirmable.host, optimum_time_slot)
    end

    it 'turns the event in a non flexible event' do
      expect(confirmable.reload).to_not be_flexible
    end
  end
end
