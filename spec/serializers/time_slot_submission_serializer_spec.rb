require 'rails_helper'

RSpec.describe TimeSlotSubmissionSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:time_slot_submission) { FactoryGirl.create(:time_slot_submission) }

    let(:serialized) do
      Serialized.new(described_class.new(time_slot_submission))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        time_slot_submission.slice(:created_at)
      )
    end

    %w(time_slot profile).each do |relation_name|
      it "serializes the #{relation_name} relation" do
        expect(serialized.relationships).to have_key(relation_name)
      end
    end
  end
end
