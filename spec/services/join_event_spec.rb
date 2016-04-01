require 'rails_helper'

RSpec.describe JoinEvent do
  let(:profile) { Profile.new }

  let(:event)   { Event.new }

  let(:service) { JoinEvent.new(profile, event) }

  it 'has a new submission for this profile/event' do
    expect(service.new_submission).to be_a(Submission)
  end

  describe '#call' do
    subject(:call) { service.call }

    context 'when event has auto_accept' do
      let(:confirm_service) { double(call: true) }

      before do
        allow(event).to receive(:auto_accept?).and_return(true)

        allow(ConfirmSubmission).to receive(:new).and_return(confirm_service)

        call
      end

      it 'return the new submission' do
        is_expected.to eq(service.new_submission)
      end

      it 'uses the confirmation service' do
        expect(ConfirmSubmission).to have_received(:new).with(service.new_submission)
      end

      it 'confirms the submission' do
        expect(confirm_service).to have_received(:call).with(no_args)
      end
    end

    context "when event doesn't have auto_accept" do
      before do
        allow(event).to receive(:auto_accept?).and_return(false)

        allow(service.new_submission).to receive(:pending!)

        allow(Action).to receive(:create)

        call
      end

      it 'return the new submission' do
        is_expected.to eq(service.new_submission)
      end

      it "sets the submission to pending" do
        expect(service.new_submission).to have_received(:pending!)
      end

      it 'creates an action' do
        expect(Action).to have_received(:create).with(notify: :later,
          actor: profile, resource: event, type: :subscribe
        )
      end
    end
  end
end
