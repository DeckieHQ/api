require 'rails_helper'

RSpec.describe ConfirmSubmission do
  let(:event) { FactoryGirl.create(:event, :with_pending_submissions) }

  let(:service) { ConfirmSubmission.new(submission) }

  let(:submission) do
    event.pending_submissions.first
  end

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it 'returns the submission' do
      is_expected.to eq(submission)
    end

    it 'confirms the submission' do
      expect(submission).to be_confirmed
    end

    context 'when event has one slot remaining' do
      let(:event) do
        FactoryGirl.create(:event_with_one_slot_remaining, :with_pending_submissions)
      end

      it 'removes the pending submissions' do
        expect(event.pending_submissions).to be_empty
      end

      it "doesn't remove the other submissions" do
        expect(event.submissions).to_not be_empty
      end
    end
  end
end
