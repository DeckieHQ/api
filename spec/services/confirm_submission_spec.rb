require 'rails_helper'

RSpec.describe ConfirmSubmission do
  describe '.for' do
    let(:submissions) { Array.new(5).map { double() } }

    subject(:services) { described_class.for(submissions) }

    it 'maps an array of submissions with this service' do
      expect(services).to all be_a(described_class)
    end
  end

  describe '#call' do
    let(:service) { described_class.new(submission) }

    let(:submission) do
      double(confirmed!: true, event: double(host: double()), profile: double())
    end

    subject(:call) { service.call }

    before do
      allow(Action).to receive(:create)
    end

    context 'when submission event is not full after confirmation' do
      before do
        allow(submission.event).to receive(:full?).and_return(false)

        call
      end

      it 'returns the submission' do
        is_expected.to eq(submission)
      end

      it 'confirms the submission' do
        expect(submission).to have_received(:confirmed!).with(no_args)
      end

      it 'creates an event action' do
        expect(Action).to have_received(:create).with(
          actor: submission.profile, resource: submission.event, type: :join
        )
      end
    end

    context 'when submission event is full after confirmation' do
      before do
        allow(submission.event).to receive(:full?).and_return(true)

        allow(submission.event).to receive(:destroy_pending_submissions)

        call
      end

      it 'returns the submission' do
        is_expected.to eq(submission)
      end

      it 'confirms the submission' do
        expect(submission).to have_received(:confirmed!).with(no_args)
      end

      it 'creates an event join action' do
        expect(Action).to have_received(:create).with(
          actor: submission.profile, resource: submission.event, type: :join
        )
      end

      it 'destroys all event pending submissions' do
        expect(submission.event).to have_received(:destroy_pending_submissions)
      end
     end
  end
end
