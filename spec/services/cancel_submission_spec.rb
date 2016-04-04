require 'rails_helper'

RSpec.describe CancelSubmission do
  describe '.for' do
    let(:submissions) { Array.new(5).map { double() } }

    let(:services) { Array.new(5).map { double(call: true) } }

    before do
      allow(described_class).to receive(:new).and_return(*services)

      described_class.for(submissions)
    end

    it "gets an instance of #{described_class} for each given submission" do
      submissions.each do |submission|
        expect(described_class).to have_received(:new).with(submission)
      end
    end

    it "call on each services of #{described_class}" do
      services.each do |service|
        expect(service).to have_received(:call).with(no_args)
      end
    end
  end

  describe '#call' do
    subject(:service) { described_class.new(submission) }

    context 'when submission is confirmed' do
      let(:submission) { FactoryGirl.create(:submission, :confirmed) }

      before { service.call }

      it 'destroys the submission' do
        expect(submission).to be_deleted
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, :leave) }
    end

    context 'when submission is not confirmed' do
      let(:submission) { FactoryGirl.create(:submission, :pending) }

      before { service.call }

      it 'destroys the submission' do
        expect(submission).to be_deleted
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, :unsubscribe) }
    end
  end
end
