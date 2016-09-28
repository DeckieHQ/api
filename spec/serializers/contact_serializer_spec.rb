require 'rails_helper'

RSpec.describe ContactSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:contact) { Contact.new(FactoryGirl.create(:user_verified)) }

    let(:serialized) do
      Serialized.new(described_class.new(contact))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        { 'email' => contact.email, 'phone_number' => contact.phone_number }
      )
    end
  end
end
