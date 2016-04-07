require 'rails_helper'

RSpec.describe AddComment do
  describe '#call' do
    subject(:call) { described_class.new(comment).call }

    let(:comment) { FactoryGirl.create(:comment) }

    it { is_expected.to eq(comment.reload) }

    it { is_expected.to have_created_action(comment.author, comment.resource, :comment) }

    it 'persists the comment' do
      expect(comment.reload).to be_persisted
    end
  end
end
