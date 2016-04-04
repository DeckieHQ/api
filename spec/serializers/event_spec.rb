require 'rails_helper'

RSpec.describe EventSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:event) { FactoryGirl.create(:event) }

    let(:serialized) do
      Serialized.new(EventSerializer.new(event))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        event.slice(
          :title, :category, :ambiance, :level, :capacity, :auto_accept,
          :description, :begin_at, :end_at, :latitude, :longitude, :street,
          :postcode, :city, :state, :country
        )
      )
    end

    %w(host).each do |relation_name|
      it "serializes the #{relation_name} relation" do
        expect(serialized.relationships).to have_key(relation_name)
      end
    end
  end
end
