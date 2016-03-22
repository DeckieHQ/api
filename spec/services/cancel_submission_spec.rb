require 'rails_helper'

RSpec.describe CancelSubmission do
  describe '.for' do
    let(:submissions) { Array.new(5).map { double() } }

    subject(:services) { described_class.for(submissions) }

    it 'maps an array of submissions with this service' do
      expect(services).to all be_a(described_class)
    end
  end

  describe '#call' do
    let(:service) { described_class.new(submission) }

    subject(:call) { service.call }

    context 'when submission is confirmed' do
      let(:submission) do
        double(destroy: true, event: double(), profile: double(), confirmed?: true)
      end

      before do
        allow(Action).to receive(:create)

        call
      end

      it 'destroys the submission' do
        expect(submission).to have_received(:destroy).with(no_args)
      end

      it 'creates an action' do
        expect(Action).to have_received(:create).with(
          actor: submission.profile, resource: submission.event, type: :leave
        )
      end
    end

    context 'when submission is not confirmed' do
      let(:submission) { double(destroy: true, confirmed?: false) }

      before { call }

      it 'destroys the submission' do
        expect(submission).to have_received(:destroy).with(no_args)
      end
    end
  end
end
