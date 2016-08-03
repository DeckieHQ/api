require 'rails_helper'

RSpec.describe UserSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:user) { FactoryGirl.create([:user, :user_verified].sample) }

    let(:serialized) do
      Serialized.new(UserSerializer.new(user))
    end

    it 'serializes the specified attributes' do
      expected_attributes = user.slice(
        :first_name, :last_name, :birthday, :email, :phone_number, :culture,
        :notifications_count, :moderator
      ).merge({
        email_verified: user.email_verified?,
        phone_number_verified: user.phone_number_verified?
      })
      expect(serialized.attributes).to have_serialized_attributes(expected_attributes)
    end

    it 'adds the profile link' do
      expect(serialized).to have_relationship_link_for(:profile, target: user.profile)
    end

    it 'adds the preferences link' do
      expect(serialized).to have_relationship_link_for(
        :preferences, target: Preferences.for(user).id, singularize: true
      )
    end

    [:hosted_events, :submissions, :notifications].each do |link|
      it "adds the #{link} link" do
        expect(serialized).to have_relationship_link_for(link)
      end
    end
  end
end
