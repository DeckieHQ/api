require 'rails_helper'

RSpec.describe EventSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:event) { FactoryGirl.create(:event) }

    let(:serialized) do
      Serialized.new(EventSerializer.new(event))
    end

    it 'serializes the specified attributes' do
      expected_attributes = event.slice(
        :title, :category, :ambiance, :level, :capacity, :auto_accept,
        :description, :begin_at, :end_at, :latitude, :longitude, :street,
        :postcode, :city, :state, :country, :attendees_count
      ).merge({
        opened: !event.closed?,
        full:    event.full?
      })
      expect(serialized.attributes).to have_serialized_attributes(expected_attributes)
    end

    it "serializes the host relation" do
      expect(serialized.relationships).to have_key('host')
    end

    it 'adds the comments link' do
      expect(serialized).to have_relationship_link_for(:comments, source: event)
    end

    it 'adds the private comments link' do
      expect(serialized).to have_relationship_link_for(
        :comments, source: event, key: 'private_comments', args: '?private=true'
      )
    end
  end
end
