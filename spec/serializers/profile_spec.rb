require 'rails_helper'

RSpec.describe ProfileSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:profile) { FactoryGirl.create([:profile, :profile_verified].sample) }

    let(:serialized) do
      Serialized.new(ProfileSerializer.new(profile))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        profile.slice(
          :nickname, :display_name, :short_description, :description,
          :hosted_events_count, :email_verified, :phone_number_verified,
          :created_at, :deleted_at
        ).merge(
          avatar_url: profile.avatar.url,
          deleted:    profile.deleted?
        )
      )
    end
  end
end
