require 'rails_helper'

RSpec.describe CancelSubmission do
  describe '.for' do
    let(:submissions) { Array.new(5).map { double() } }

    let(:services) { Array.new(5).map { double(call: true) } }

    before do
      allow(described_class).to receive(:new).and_return(*services)
    end

    it "gets an instance of #{described_class} for each given submission" do
      described_class.for(submissions)

      submissions.each do |submission|
        expect(described_class).to have_received(:new).with(submission)
      end
    end

    context 'when reason is not specified' do
      before { described_class.for(submissions) }

      it "call on each services of #{described_class} with default reason" do
        services.each do |service|
          expect(service).to have_received(:call).with(:quit)
        end
      end
    end

    context 'when reason is  specified' do
      let(:reason) { [:remove_full, :remove_start].sample }

      before { described_class.for(submissions, reason: reason) }

      it "call on each services of #{described_class} with default reason" do
        services.each do |service|
          expect(service).to have_received(:call).with(reason)
        end
      end
    end
  end

  describe '#call' do
    subject(:service) { described_class.new(submission) }

    context 'when reason is specified' do
      let(:submission) { FactoryGirl.create(:submission) }

      let(:reason) { [:remove_full, :remove_start].sample }

      before { service.call(reason) }

      it 'destroys the submission' do
        expect(submission).to be_deleted
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, reason) }
    end

    context 'when reason is not specified' do
      context 'when submission is confirmed' do
        let(:submission) { FactoryGirl.create(:submission, :confirmed) }

        context 'when event is almost ready after cancellation' do
          before do
            allow(submission.event).to receive(:just_ready?).and_return(true)

            service.call
          end

          it 'destroys the submission' do
            expect(submission).to be_deleted
          end

          it { is_expected.to have_created_action(submission.profile, submission.event, :leave) }

          it { is_expected.to have_created_action(submission.profile, submission.event, :not_ready) }
        end

        context 'when event is not almost ready after cancellation' do
          before do
            allow(submission.event).to receive(:just_ready?).and_return(false)

            service.call
          end

          it 'destroys the submission' do
            expect(submission).to be_deleted
          end

          it { is_expected.to have_created_action(submission.profile, submission.event, :leave) }

          it { is_expected.to_not have_created_action(submission.profile, submission.event, :not_ready) }
        end
      end

      context 'when submission is not confirmed' do
        let(:submission) { FactoryGirl.create(:submission, :pending) }

        before { service.call }

        it 'destroys the submission' do
          expect(submission).to be_deleted
        end

        it { is_expected.to have_created_action(submission.profile, submission.event, :unsubmit) }

        it { is_expected.to_not have_created_action(submission.profile, submission.event, :not_ready) }
      end
    end
  end
end
