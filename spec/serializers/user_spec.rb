require 'rails_helper'

RSpec.describe UserSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:user) { FactoryGirl.create(:user) }

    let(:serialized) do
      Serialized.new(UserSerializer.new(user))
    end

    it 'serializes the specified attributes' do
      expected_attributes = user.slice(
        :first_name, :last_name, :birthday, :email, :phone_number, :culture
      )

      expected_attributes[:email_verified] = user.email_verified?
      expected_attributes[:phone_number_verified] = user.phone_number_verified?

      expect(serialized.attributes).to have_serialized_attributes(expected_attributes)
    end

    it 'adds the profile link' do
      expect(serialized).to have_relationship_link_for(:profile, user.profile)
    end

    it 'adds the hosted events link' do
      expect(serialized).to have_relationship_link_for :hosted_events
    end
  end
end
