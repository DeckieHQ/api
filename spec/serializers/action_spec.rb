require 'rails_helper'

RSpec.describe ActionSerializer, :type => :serializer do
  context 'Individual Resource Representation' do
    let(:action) { FactoryGirl.create(:action) }

    let(:serialized) do
      Serialized.new(ActionSerializer.new(action))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        action.slice(:title, :type, :created_at, :updated_at)
      )
    end

    %w(actor resource).each do |relation_name|
      it "serializes the #{relation_name} relation" do
        expect(serialized.relationships).to have_key(relation_name)
      end
    end
  end
end
