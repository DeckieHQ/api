require 'rails_helper'

RSpec.describe CancelSubmission do
  let(:event) { FactoryGirl.create(:event, :with_pending_submissions) }

  let(:service) { CancelSubmission.new(submission) }

  let(:submission) { event.submissions.last }

  describe '#call' do
    subject(:call) { service.call }

    before { call }

    it { is_expected.to be_truthy }

    it 'destroys the submission' do
      expect(submission).to_not be_persisted
    end
  end
end
