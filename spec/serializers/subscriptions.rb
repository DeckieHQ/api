require 'rails_helper'

RSpec.describe ProfileSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:subscription) { FactoryGirl.create(:subscription) }

    let(:serialized) do
      Serialized.new(SubscriptionSerializer.new(subscription))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        subscription.slice(:status, :created_at, :updated_at)
      )
    end

    %w(profile event).each do |relation_name|
      it "serializes the #{relation_name} relation" do
        expect(serialized.relationships).to have_key(relation_name)
      end
    end
  end
end
