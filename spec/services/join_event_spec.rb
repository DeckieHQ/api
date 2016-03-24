require 'rails_helper'

RSpec.describe JoinEvent do
  let(:profile) { double() }

  let(:event) { double() }

  let(:service) { JoinEvent.new(profile, event) }

  describe '#call' do
    subject(:call) { service.call }

    let(:new_submission) { double() }

    before do
      allow(Submission).to receive(:create).and_return(new_submission)
    end

    context 'when event has auto_accept' do
      let(:event) { double(auto_accept?: true) }

      let(:confirm_service) { double(call: true) }

      before do
        allow(ConfirmSubmission).to receive(:new).and_return(confirm_service)

        call
      end

      it 'return the new submission' do
        is_expected.to eq(new_submission)
      end

      it 'uses the confirmation service' do
        expect(ConfirmSubmission).to have_received(:new).with(new_submission)
      end

      it 'confirms the submission' do
        expect(confirm_service).to have_received(:call).with(no_args)
      end
    end

    context "when event doesn't have auto_accept" do
      let(:event) { double(auto_accept?: false) }

      before do
        allow(Action).to receive(:create)

        call
      end

      it 'return the new submission' do
        is_expected.to eq(new_submission)
      end

      it 'creates an action' do
        expect(Action).to have_received(:create).with(notify: :later,
          actor: profile, resource: event, type: :subscribe
        )
      end
    end
  end
end
