require 'rails_helper'

RSpec.describe ProfileSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:profile) { FactoryGirl.create([:profile, :profile_verified].sample) }

    let(:serialized) do
      Serialized.new(described_class.new(profile))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        profile.slice(
          :nickname, :display_name, :short_description, :description,
          :hosted_events_count, :email_verified, :phone_number_verified,
          :moderator, :created_at, :deleted_at
        ).merge(
          avatar_url: profile.avatar.url,
          deleted:    profile.deleted?
        )
      )
    end

    it 'adds the contact link' do
      expect(serialized).to have_relationship_link_for(:contact, target: profile.user_id)
    end

    it 'adds the achievements link' do
      expect(serialized).to have_relationship_link_for(:achievements, source: profile)
    end
  end
end
