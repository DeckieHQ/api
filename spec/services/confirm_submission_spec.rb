require 'rails_helper'

RSpec.describe ConfirmSubmission do
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
    subject(:call) { described_class.new(submission).call }

    let(:submission) { FactoryGirl.create(:submission, :pending) }

    before do
      allow(CancelSubmission).to receive(:for)
    end

    context 'when event is not full after confirmation' do
      before do
        allow(submission.event).to receive(:full?).and_return(false)
      end

      it 'confirms and return the submission' do
        is_expected.to eq(submission.reload).and be_confirmed
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, :join) }

      it "doesn't remove the pending submissions" do
        call

        expect(CancelSubmission).to_not have_received(:for)
      end
    end

    context 'when event is full after confirmation' do
      before do
        allow(submission.event).to receive(:full?).and_return(true)
      end

      it 'confirms and return the submission' do
        is_expected.to eq(submission.reload).and be_confirmed
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, :join) }

      it 'removes the pending submissiosn' do
        call

        expect(CancelSubmission).to have_received(:for)
          .with(submission.event.pending_submissions, reason: :remove_full)
      end
    end

    context 'when event becomes ready after confirmation' do
      before do
        allow(submission.event).to receive(:just_ready?).and_return(true)
      end

      it 'confirms and return the submission' do
        is_expected.to eq(submission.reload).and be_confirmed
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, :ready) }
    end

    context "when event doesn't become ready after confirmation" do
      before do
        allow(submission.event).to receive(:just_ready?).and_return(false)
      end

      it 'confirms and return the submission' do
        is_expected.to eq(submission.reload).and be_confirmed
      end

      it { is_expected.to_not have_created_action(submission.profile, submission.event, :ready) }
    end
  end
end
