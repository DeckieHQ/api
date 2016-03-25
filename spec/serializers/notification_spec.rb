require 'rails_helper'

RSpec.describe NotificationSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:notification) { FactoryGirl.create(:notification) }

    let(:serialized) do
      Serialized.new(NotificationSerializer.new(notification))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        notification.slice(:type, :viewed)
      )
    end

    %w(user action).each do |relation_name|
      it "serializes the #{relation_name} relation" do
        expect(serialized.relationships).to have_key(relation_name)
      end
    end
  end
end
