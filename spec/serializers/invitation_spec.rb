require 'rails_helper'

RSpec.describe InvitationSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:invitation) { FactoryGirl.create(:invitation) }

    let(:serialized) do
      Serialized.new(described_class.new(invitation))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        invitation.slice(:email, :message, :created_at)
      )
    end

    it "serializes the event relation" do
      expect(serialized.relationships).to have_key('event')
    end
  end
end
