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
    let(:service) { described_class.new(submission) }

    let(:submission) do
      double(confirmed!: true, event: event, profile: double())
    end

    subject(:call) { service.call }

    before do
      allow(Action).to receive(:create)
    end

    context 'when event is not full after confirmation' do
      let(:event) { double(host: double(), full?: false) }

      before { call }

      it 'returns the submission' do
        is_expected.to eq(submission)
      end

      it 'confirms the submission' do
        expect(submission).to have_received(:confirmed!).with(no_args)
      end

      it 'creates an event action' do
        expect(Action).to have_received(:create).with(notify: :later,
          actor: submission.profile, resource: submission.event, type: :join
        )
      end
    end

    context 'when event is full after confirmation' do
      let(:event) { double(host: double(), full?: true) }

      let(:event_ready_service) { double(call: true) }

      before do
        allow(EventReady).to receive(:new).and_return(event_ready_service)

        call
      end

      it 'returns the submission' do
        is_expected.to eq(submission)
      end

      it 'confirms the submission' do
        expect(submission).to have_received(:confirmed!).with(no_args)
      end

      it 'creates an event action' do
        expect(Action).to have_received(:create).with(notify: :later,
          actor: submission.profile, resource: submission.event, type: :join
        )
      end

      it 'uses the event ready service' do
        expect(EventReady).to have_received(:new).with(event)
      end

      it 'calls the event ready service' do
        expect(event_ready_service).to have_received(:call).with(:full)
      end
    end
  end
end
