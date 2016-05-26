require 'rails_helper'

RSpec.describe AchievementSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:achievement) { Merit::Badge.find(1) }

    let(:serialized) do
      Serialized.new(AchievementSerializer.new(achievement))
    end

    it 'has an achievements type' do
      expect(serialized.type).to eq('achievements')
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        achievement.attributes.slice('name', 'description')
      )
    end
  end
end
