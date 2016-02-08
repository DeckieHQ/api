require 'rails_helper'

RSpec.describe ProfileSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:profile) { FactoryGirl.create(:profile) }

    let(:serialized) do
      Serialized.new(ProfileSerializer.new(profile))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        profile.slice(:nickname, :display_name, :short_description, :description)
      )
    end
  end
end
