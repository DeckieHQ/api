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
    let(:service) { described_class.new(submission) }

    subject(:call) { service.call }

    let(:submission) do
      double(destroy: true, event: double(), profile: double())
    end

    before do
      allow(Action).to receive(:create)
    end

    context 'when submission is confirmed' do
      before do
        allow(submission).to receive(:confirmed?).and_return(true)

        call
      end

      it 'destroys the submission' do
        expect(submission).to have_received(:destroy).with(no_args)
      end

      it 'creates an action' do
        expect(Action).to have_received(:create).with(notify: :later,
          actor: submission.profile, resource: submission.event, type: :leave
        )
      end
    end

    context 'when submission is not confirmed' do
      before do
        allow(submission).to receive(:confirmed?).and_return(false)

        call
      end

      it 'destroys the submission' do
        expect(submission).to have_received(:destroy).with(no_args)
      end

      it 'creates an action' do
        expect(Action).to have_received(:create).with(notify: :later,
          actor: submission.profile, resource: submission.event, type: :unsubscribe
        )
      end
    end
  end
end
