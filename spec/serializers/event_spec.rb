require 'rails_helper'

RSpec.describe EventSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:event) { FactoryGirl.create(:event) }

    let(:serialized) do
      Serialized.new(EventSerializer.new(event))
    end

    it 'serializes the specified attributes' do
      expected_attributes = event.slice(
        :title, :category, :ambiance, :level, :capacity, :min_capacity, :auto_accept,
        :short_description, :description, :begin_at, :end_at, :begin_at_range, :latitude, :longitude,
        :street, :postcode, :city, :state, :country, :attendees_count, :submissions_count,
        :public_comments_count, :private_comments_count, :private, :flexible
      ).merge({
        opened: !event.closed?,
        full:    event.full?,
        ready:   event.ready?,
        reached_time_slot_min: event.reached_time_slot_min?
      })
      expect(serialized.attributes).to have_serialized_attributes(expected_attributes)
    end

    it "serializes the host relation" do
      expect(serialized.relationships).to have_key('host')
    end

    it 'adds the user submission link' do
      expect(serialized).to have_relationship_link_for(
        :submission, source: event, key: 'user_submission'
      )
    end

    [:attendees, :submissions, :comments, :invitations, :time_slots].each do |link|
      it "adds the #{link} link" do
        expect(serialized).to have_relationship_link_for(link, source: event)
      end
    end
  end
end
