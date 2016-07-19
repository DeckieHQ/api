require 'rails_helper'

RSpec.describe TimeSlotSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:time_slot) { FactoryGirl.create(:time_slot) }

    let(:serialized) do
      Serialized.new(described_class.new(time_slot))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        time_slot.slice(:begin_at, :created_at).merge({
          full: time_slot.full?
        })
      )
    end

    it 'adds the event link' do
      expect(serialized).to have_relationship_link_for(:event, target: time_slot.event_id)
    end

    it 'adds the members link' do
      expect(serialized).to have_relationship_link_for(:members, source: time_slot)
    end
  end
end
