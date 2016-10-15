require 'rails_helper'

RSpec.describe TimeSlotSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:time_slot) { FactoryGirl.create(:time_slot) }

    let(:serialized) do
      Serialized.new(described_class.new(time_slot))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        time_slot.slice(:begin_at, :created_at, :members_count).merge({
          full: time_slot.full?, member: false
        })
      )
    end

    it "serializes the event relation" do
      expect(serialized.relationships).to have_key('event')
    end

    [:members, :time_slot_submissions].each do |link|
      it "adds the #{link} link" do
        expect(serialized).to have_relationship_link_for(link, source: time_slot)
      end
    end
  end
end
