require 'rails_helper'

RSpec.describe LocationSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:location) { FactoryGirl.build(:location) }

    let(:serialized) { Serialized.new(described_class.new(location)) }

    it 'has an empty id' do
      expect(serialized.id).to eq('0')
    end

    it 'has a locations type' do
      expect(serialized.type).to eq('locations')
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        location.instance_values.slice('latitude', 'longitude')
      )
    end
  end
end
