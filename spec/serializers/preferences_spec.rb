require 'rails_helper'

RSpec.describe PreferencesSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:preferences) { FactoryGirl.build(:preferences) }

    let(:serialized) do
      Serialized.new(PreferencesSerializer.new(preferences))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to eq(
        preferences.attributes.slice('notifications')
      )
    end

    it 'has an empty id' do
      expect(serialized.id).to eq('')
    end
  end
end
