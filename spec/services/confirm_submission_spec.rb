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

    let(:event_ready_service) { double(call: true) }

    before do
      allow(EventReady).to receive(:new).and_return(event_ready_service)
    end

    context 'when event is not full after confirmation' do
      before do
        allow(submission.event).to receive(:full?).and_return(false)
      end

      it 'confirms and return the submission' do
        is_expected.to eq(submission.reload).and be_confirmed
      end

      it { is_expected.to have_created_action(submission.profile, submission.event, :join) }

      it "doesn't call the event ready service" do
        call

        expect(EventReady).to_not have_received(:new)
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

      it 'calls the event ready service with this event' do
        call

        expect(EventReady).to have_received(:new).with(submission.event)

        expect(event_ready_service).to have_received(:call).with(:full)
      end
    end
  end
end
