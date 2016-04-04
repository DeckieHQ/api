require 'rails_helper'

RSpec.describe CommentSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:comment) { FactoryGirl.create(:comment) }

    let(:serialized) do
      Serialized.new(CommentSerializer.new(comment))
    end

    it 'serializes the specified attributes' do
      expect(serialized.attributes).to have_serialized_attributes(
        comment.slice(:message, :private, :created_at)
      )
    end

    it "serializes the author relation" do
      expect(serialized.relationships).to have_key('author')
    end

    it 'adds the comments link' do
      expect(serialized).to have_relationship_link_for(:comments, source: comment)
    end
  end
end
