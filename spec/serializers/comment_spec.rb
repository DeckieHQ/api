require 'rails_helper'

RSpec.describe CommentSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:comment) { FactoryGirl.create(:comment) }

    let(:serialized) do
      Serialized.new(CommentSerializer.new(comment))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        comment.slice(:message)
      )
    end
  end
end
