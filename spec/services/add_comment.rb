require 'rails_helper'

RSpec.describe AddComment do
  describe '#call' do
    subject(:call) { described_class.new(comment).call }

    let(:comment) { FactoryGirl.create(:comment) }

    it { is_expected.to eq(comment.reload) }

    it { is_expected.to have_created_action(comment.author, comment.resource, :comment) }
  end
end
