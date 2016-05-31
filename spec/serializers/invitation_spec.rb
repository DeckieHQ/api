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

    %w(sender event).each do |relation_name|
      it "serializes the #{relation_name} relation" do
        expect(serialized.relationships).to have_key(relation_name)
      end
    end
  end
end
