require 'rails_helper'

RSpec.describe CancelComment do
  let(:service) { CancelComment.new(comment) }

  let(:comment) { FactoryGirl.create(:comment) }

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it { is_expected.to be_truthy }

    it 'destroys the comment' do
      expect(comment).to_not be_persisted
    end
  end
end
